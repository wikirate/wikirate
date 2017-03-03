#! no set module

class Badges
  NAMES = ["Researcher", "Research Engine", "Research Fellow"]
  @levels = [:gold, :silver, :bronze]

  @badge_level = {
    researcher: :bronze,
    research_engine: :silver,
    research_fellow: :gold
  }

  def self.badge_set *levels
    hash = {}
    levels.each.with_index do |level, i|
      hash[NAMES[i]].to_name.key] = level
      hash[level] = NAMES[i]
    end
    hash
  end

  @map = {
    create: {
      general:  badge_set(1, 50, 100),
      designer: badge_set(10, 100, 250),
      company:  badge_set(3, 50, 100),
      project:  badge_set(5, 75, 150)
    }
  }

  class << self
    attr_reader :badge_level, :levels

    # returns a badge if the treshold is reached
    def earns_badge action, affinity_type, count
      validate_badge_args action, type
      @map[action][affinity_type][count]
    end

    def validate_badge_args action, type
      unless @map[action].is_a? Hash
        raise StandardError, "not supported action: #{action}"
      end
      unless @map[action][type].is_a? Hash
        raise StandardError, "not supported type: #{type}"
      end
    end

    def map
      @map
    end

    def threshold action, affinity_type, badge_key
      validate_badge_args action, type
      @map[action][affinity_type][badge_key]
    end

    def change_thresholds action, map
      @map[action] = map
    end
  end

  def initialize card
    @badges =
      self.class.levels.each_with_object({}) do |level, hash|
        hash[level] = []
      end

    card.item_cards.each do |badge_card|
      if badge_card.cardname.simple?
        add_simple_badge badge_card.cardname
      else
        add_junction_badge badge_card.cardname
      end
    end
  end

  def badge_level badge_name
    self.class.badge_level[badge_name]
  end

  def items
    self.class.levels.map do |level|
      @badges[level]
    end.flatten
  end

  @levels.each do |level|
    define_method "#{level}_items" do
      @badges[level]
    end
  end

  private

  def add_simple_badge badge_name
    key = badge_name.key
    level = badge_level key
    @badges[level].unshift key
  end

  def add_junction_badge badge_name
    level = badge_level badge_name.right_key
    @badges[level] << badge_name
  end
end
