#! no set module

class Thresholds

  # returns a badge if the treshold is reached
  def self.badge action, type, count
    validate_badge_args action, type
    @map[action][type][count]
  end

  def self.validate_badge_args action, type
    unless @map[action].is_a? Hash
      binding.pry
      raise StandardError, "not supported action: #{action}"
    end
    unless @map[action][type].is_a? Hash
      raise StandardError, "not supported type: #{type}"
    end
  end

  def self.map
    @map
  end

  def self.change_thresholds action, map
    @map[action] = map
  end

  @map = {
    create: {
      general: {
        1 => "Researcher",
        50 => "Research Engine",
        100 => "Research Fellow"
      },
      designer: {
        10 => "Researcher",
        100 => "Research Engine",
        250 => "Research Fellow"
      },
      company: {
        3 => "Researcher",
        50 => "Research Engine",
        100 => "Research Fellow"
      },
      project: {
        5 => "Researcher",
        75 => "Research Engine",
        150 => "Research Fellow"
      }
    }
  }

  @map[:create] =
    @map[:create].each do |k, hash|
      @map[:create][k] = hash.merge! hash.invert
    end
end
