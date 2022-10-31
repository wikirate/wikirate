
class Card
  # a BadgeLine is a ranking of badges for one category, i.e. it has one
  # badge for every level
  class BadgeLine
    LEVELS = [:bronze, :silver, :gold].freeze

    Badge = Struct.new :codename, :threshold, :level, :level_index

    def initialize map, &block
      @badge_codes = []
      @badge = {}
      map.each.with_index do |(codename, threshold), i|
        initialize_badge codename, threshold, i
      end
      @count_cql = block
    end

    def initialize_badge codename, threshold, index
      if threshold.is_a? Array
        threshold, level = threshold
        level_index = LEVELS.index(level)
      else
        level_index = index
        level = LEVELS[index]
      end

      badge = Badge.new codename, threshold, level, level_index
      validate_threshold badge.threshold
      add_badge badge
    end

    def add_badge badge
      @badge_codes << badge.codename
      @badge[badge.codename] = badge
      @badge[badge.codename.to_s] = badge
      @badge[badge.threshold] = badge
      @badge[badge.level] = badge
    end

    def badge_names
      @badge_codes.map(&:cardname)
    end

    def validate_threshold threshold
      raise ArgumentError, "thresholds have to be positive" if threshold < 1
      raise ArgumentError, "thresholds have to be unique" if @badge[threshold]
    end

    def earns_badge count=nil
      count ||= count_valued_actions
      @badge[count]&.codename&.cardname
    rescue Card::Error::CodenameNotFound
      puts "badge failure"
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
      LEVELS.map { |level| earned_badge_name @badge[level], count }.compact
    end

    def earned_badge_name badge, count
      badge.codename&.cardname if badge && badge.threshold <= count
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
      # FIXME: this is a temporary solution so we can keep supporting name arguments
      @badge[mark] || @badge.fetch(mark.to_name.codename) do
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

    def cache
      Card::Cache[BadgeLine]
    end
  end
end
