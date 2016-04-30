# encoding: UTF-8

class Formula
  def initialize formula_card
    formula = formula_card.content
    calc_class =
      if formula_card.wiki_rating?
        WikiRating
      elsif Translation.valid_formula? formula
        Translation
      elsif Ruby.valid_formula? formula
        Ruby
      else
        Wolfram
      end
    @calculator = calc_class.new formula_card
  end


  # @param [Hash] opts
  # @option opts [String] :company
  # @option opts [String] :year
  # @return [Hash] { year => { company => value } }
  def evaluate opts={}
    @calculator.result opts
  end
end
