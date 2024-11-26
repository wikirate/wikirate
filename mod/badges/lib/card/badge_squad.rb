class Card
  # A BadgeSquad manages BadgeLines for one badge cardtype, for example
  # all badges related to answers
  module BadgeSquad
    BADGE_TYPES =
      [:metric, :project, :answer, :source, :company].freeze

    def self.for_type type_code
      Card::Set::Type.const_get("#{type_code.to_s.camelcase}::BadgeSquad")
    end

    attr_reader :badge_level, :levels, :levels_descending, :badge_action

    def add_badge_line action, badge_line, &count_cql
      @map ||= {}
      @map[action] = BadgeLine.new badge_line, &count_cql
    end

    def add_affinity_badge_line action, map
      @map ||= {}
      @map[action] = {}
      map.each do |affinity, affinity_badge_line|
        @map[action][affinity] = BadgeLine.new affinity_badge_line
      end
    end

    def create_type_count type
      lambda do |user_id|
        { type: type, created_by: user_id }
      end
    end

    def type_plus_right_count type, right, relation_to_user
      lambda do |user_id|
        { left: { type: type },
          right: right,
          relation_to_user => user_id }
      end
    end

    def type_plus_right_edited_count type_id, right_id
      type_plus_right_count(type_id, right_id, :edited_by)
    end

    def bookmark_count type
      lambda do |user_id|
        for_bookmarker user_id do |bookmarks_card_id|
          { type: type, referred_to_by: bookmarks_card_id }
        end
      end
    end

    def for_bookmarker user_id
      user = user_id ? Card[user_id] : Auth.current
      return unless (bookmarks_card_id = user&.try(:bookmarks_card)&.id)

      yield bookmarks_card_id
    end

    # returns a badge if the threshold is reached
    def earns_badge action, affinity_type=nil, count=nil
      badge_line(action, affinity_type).earns_badge count
    end

    def all_earned_badges action, affinity_type=nil, count=nil, user_id=nil
      badge_line(action, affinity_type)
        .all_earned_badges count, user_id || Auth.current_id
    end

    [:threshold, :level, :level_index].each do |method_name|
      define_method method_name do |action, affinity_type, badge_key|
        badge_line(action, affinity_type).send method_name, badge_key
      end
    end

    def count action
      badge_line(action, nil).count_valued_actions
    end

    def badge_line action, affinity_type
      validate_badge_args action, affinity_type
      affinity_type ? @map[action][affinity_type] : @map[action]
    end

    def validate_badge_args action, affinity_type
      error =
        if !@map[action]
          "not supported action: #{action}"
        elsif affinity_type &&
              !@map[action][affinity_type].is_a?(BadgeLine)
          "affinity type #{affinity_type} not supported for action #{action}"
        end
      raise StandardError, error if error
    end

    def map
      @map
    end

    def badge_names
      @map.values.map do |badge_line|
        # handle affinity badges
        badge_line = badge_line[:general] if badge_line.is_a? Hash
        badge_line.badge_names
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
end
