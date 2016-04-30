# encoding: UTF-8


# -5 .. -3 2015  2018 .. 2020
class Formula
  def initialize formula_card
    @formula = formula_card
    @calculator =
      if formula_card.wiki_rating?
        Calculator::WikiRating.new formula_card
      elsif Calculator::Translation.valid_formula? formula_card.content
        Calculator::Translation.new formula_card
      elsif Calculator::Ruby.valid_formula? formula_card.content
        Calculator::Ruby.new formula_card
      else
        Calculator::Wolfram.new formula_card
      end
  end


  # @param [Hash] opts
  # @option opts [String] :company
  # @option opts [String] :year
  # @return [Hash] { year => { company => value } }
  def evaluate opts={}
    @calculator.result opts
  end
end
