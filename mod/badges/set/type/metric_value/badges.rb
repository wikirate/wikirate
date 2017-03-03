class Badges
  @levels = [:gold, :silver, :bronze]

  @badge_level = {
    researcher: :bronze,
    research_engine: :silver,
    research_fellow: :gold
  }

  class << self
    attr_reader :badge_level, :levels
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
