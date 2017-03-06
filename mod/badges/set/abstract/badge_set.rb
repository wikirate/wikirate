#! no set module

class BadgeSet
  LEVELS = [:bronze, :silver, :gold]

  def initialize map
    @badge_names_by_threshold = {}
    @thresholds = {}
    @badge_names = []
    @badge_level = {}
    @badge_level_index = {} # used for sorting
    map.each.with_index do |(badge_codename, threshold), i|
      # Card.fetch not defined at this point
      if threshold.is_a? Array
        threshold, level = threshold
        level_index = LEVELS.index(level)
      else
        level_index = i
        level = LEVELS[i]
      end
      badge_name =
        Card.where(id: Card::Codename[badge_codename]).pluck(:name).first
      @badge_names << badge_name
      @badge_names_by_threshold[threshold] = badge_name

      @badge_level[badge_name] = level
      @badge_level[badge_codename] = level

      @badge_level_index[badge_name] = level_index
      @badge_level_index[badge_codename] = level_index

      @thresholds[badge_name] = threshold
      @thresholds[badge_codename] = threshold
    end
  end

  def earns_badge count
    @badge_names_by_threshold[count]
  end

  # @return threshold for a given badge name or codename symbol
  def threshold badge_name
    @thresholds[badge_name]
  end

  def level badge_name
    @badge_level[badge_name]
  end

  def level_index badge_name
    @badge_level_index[badge_name]
  end

  def change_thresholds *thresholds
    @badge_names_by_threshold = {}
    thresholds.each.with_index do |count, i|
      @badge_names_by_threshold[i] = @badge_names[count]
    end
  end
end
