#! no set module

class BadgeSet
  LEVELS = [:bronze, :silver, :gold]

  Badge =
    Struct.new("Badge", :name, :codename, :threshold, :level, :level_index)
  def initialize map
    @badge_names = []
    @badge = {}
    map.each.with_index do |(codename, threshold), i|
      badge = initialize_badge codename, threshold, i
      validate_threshold threshold

      @badge_names << badge.name
      @badge[badge.name] = badge
      @badge[badge.codename] = badge
      @badge[badge.codename.to_s] = badge
      @badge[badge.threshold] = badge
      @badge[badge.level] = badge
    end
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

    Badge.new name, codename, threshold, level, level_index
  end

  def validate_threshold threshold
    return unless @badge[threshold]
    raise ArgumentError, "thresholds have to be unique"
  end

  def earns_badge count
    @badge[count] && @badge[count].name
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
      binding.pry
      raise ArgumentError, "badge #{mark} doesn't exist"
    end
  end

  # list of thresholds or hash that sets thresholds explicitly
  def change_thresholds *thresholds
    unless thresholds.first.is_a? Hash
      return change_thresholds LEVELS.zip(thresholds).to_h
    end
    thresholds.first.each do |k, new_threshold|
      badge = @badge[k]
      @badge.delete badge.threshold
      badge.threshold = new_threshold
      @badge[new_threshold] = badge
    end
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
    id = Card::Codename[codename]
    # raise ArgumentError, "not a codename: #{codename}" unless id
    # Card.fetch not defined at this point
    Card.where(id: id).pluck(:name).first
  end
end
