#! no set module

# a BadgeLine is a ranking of badges for one category, i.e. it has one
# badge for every level
class BadgeLine
  LEVELS = [:bronze, :silver, :gold].freeze

  Badge = Struct.new :name, :codename, :threshold, :level, :level_index

  attr_reader :badge_names

  def initialize map, &block
    @badge_names = []
    @badge = {}
    map.each.with_index do |(codename, threshold), i|
      initialize_badge codename, threshold, i
    end
    @count_cql = block
  end

  def initialize_badge codename, threshold, index
    name = name_from_codename codename
    if threshold.is_a? Array
      threshold, level = threshold
      level_index = LEVELS.index(level)
    else
      level_index = index
      level = LEVELS[index]
    end

    badge = Badge.new name, codename, threshold, level, level_index
    validate_threshold badge.threshold
    add_badge badge
  end

  def add_badge badge
    @badge_names << badge.name
    @badge[badge.name] = badge
    @badge[badge.codename] = badge
    @badge[badge.codename.to_s] = badge
    @badge[badge.threshold] = badge
    @badge[badge.level] = badge
  end

  def validate_threshold threshold
    raise ArgumentError, "thresholds have to be positive" if threshold < 1
    raise ArgumentError, "thresholds have to be unique" if @badge[threshold]
  end

  def earns_badge count=nil
    count ||= count_valued_actions
    @badge[count]&.name
  end

  def count_valued_actions user_id=nil
    user_id ||= Card::Auth.current_id
    return 0 unless user_id != Card::WagnBotID && (cql = count_cql user_id)
    Card.search cql
  end

  def count_cql user_id
    cql = @count_cql.call(user_id)
    return unless cql.present? && cql.is_a?(Hash)
    cql.merge return: :count
  end

  def all_earned_badges count=nil, user_id=nil
    count ||= count_valued_actions user_id
    LEVELS.map do |level|
      @badge[level].name if @badge[level]&.threshold <= count
    end.compact
  end

  def threshold badge_mark
    badge(badge_mark).threshold
  end

  def level badge_mark
    badge(badge_mark).level
  end

  def level_index badge_mark
    badge(badge_mark).level_index
  end

  def badge mark
    @badge.fetch(mark) do
      raise ArgumentError, "badge #{mark} doesn't exist"
    end
  end

  # pass a list of thresholds or a hash that sets thresholds explicitly
  def change_thresholds *thresholds
    threshold_hash(*thresholds).each do |k, new_threshold|
      next unless (badge = @badge[k])
      @badge.delete badge.threshold
      badge.threshold = new_threshold
      @badge[new_threshold] = badge
    end
  end

  def threshold_hash *thresholds
    return thresholds.first if thresholds.first.is_a? Hash

    LEVELS[0, thresholds.size].zip(thresholds).to_h
  end

  def to_h value_key=nil
    @to_h ||=
      LEVELS.each_with_object({}) do |level, h|
        next unless @badge[level]
        h[@badge[level].codename] =
          if value_key
            @badge[level][value_key]
          else
            @badge.to_h
          end
      end
  end

  def name_from_codename codename
    badge_names_map[codename] || codename.cardname
  end

  def cache
    Card::Cache[BadgeLine]
  end

  def badge_names_map
    @badge_names_map ||= cache.fetch("badge_names_map") do
      Card.where(type_id: Card::BadgeID).pluck(:name, :codename)
          .each_with_object({}) do |(name, codename), h|
        # I was using `type_id: Card::BadgeID` instead of `codename:nil`,
        # but that broke some (weird?) tests
        h[codename.to_sym] = name
      end
    end
  end
end
