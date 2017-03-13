#! no set module

# A BadgeHierarchy manages BadgeSets for one badge cardtype, for example
# all badges related to metric answers
module BadgeHierarchy
  BADGE_TYPES =
    [:metric, :project, :metric_value, :source, :wikirate_company].freeze

  def self.for_type type_code
    Card::Set::Type.const_get("#{type_code.to_s.camelcase}::BadgeHierarchy")
  end

  attr_reader :badge_level, :levels, :levels_descending, :badge_action

  def add_badge_set action, badge_set, &count_wql
    @map ||= {}
    @map[action] = Abstract::BadgeSet.new badge_set, &count_wql
  end

  def add_affinity_badge_set action, map
    @map ||= {}
    @map[action] = {}
    map.each do |affinity, affinity_badge_set|
      @map[action][affinity] = Abstract::BadgeSet.new affinity_badge_set
    end
  end

  def create_type_count type_id
    lambda do |user_id|
      {
        type_id: type_id,
        created_by: user_id
      }
    end
  end

  def type_plus_right_count type_id, right_id, relation_to_user
    lambda do |user_id|
      {
        left: { type_id: type_id },
        right_id: right_id,
        relation_to_user => user_id
      }
    end
  end

  def type_plus_right_edited_count type_id, right_id
    type_plus_right_count(type_id, right_id, :edited_by)
  end

  def vote_count type_id
    lambda do |user_id|
      user = user_id ? Card[user_id] : Auth.current
      vote_card_ids = [user.upvotes_card.id, user.downvotes_card.id].compact
      next nil unless vote_card_ids.present?
      {
        type_id: type_id,
        referred_to_by: { id: ["in"] + vote_card_ids }
      }
    end
  end

  # returns a badge if the threshold is reached
  def earns_badge action, affinity_type=nil, count=nil
    badge_set(action, affinity_type).earns_badge count
  end

  def all_earned_badges action, affinity_type=nil, count=nil, user_id=nil
    badge_set(action, affinity_type)
      .all_earned_badges count, user_id || Card::Auth.current_id
  end

  [:threshold, :level, :level_index].each do |method_name|
    define_method method_name do |action, affinity_type, badge_key|
      badge_set(action, affinity_type).send method_name, badge_key
    end
  end

  def count action
    badge_set(action, nil).count_valued_actions
  end

  def badge_set action, affinity_type
    validate_badge_args action, affinity_type
    affinity_type ? @map[action][affinity_type] : @map[action]
  end

  def validate_badge_args action, affinity_type
    raise StandardError, "not supported action: #{action}" unless @map[action]
    if affinity_type && !@map[action][affinity_type].is_a?(Abstract::BadgeSet)
      raise StandardError,
            "affinity type #{affinity_type} not supported for action #{action}"
    end
  end

  def map
    @map
  end

  def badge_names
    @map.values.map do |badge_set|
      # handle affinity badges
      badge_set = badge_set[:general] if badge_set.is_a? Hash
      badge_set.badge_names
    end.compact.flatten
  end

  def badge_actions
    @badge_actions ||= @map.keys
  end

  def change_thresholds action, affinity_type, *thresholds
    if affinity_type
      @map[action][affinity_type].change_thresholds(*thresholds)
    else
      @map[action].change_thresholds(*thresholds)
    end
  end
end
