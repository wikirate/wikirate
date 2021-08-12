# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::IsicDivisionFormula do
  describe "compute" do
    it "finds unique leading two digits" do
      expect(Card[:isic_division_formula].calculator.compute([%w[123 125 432]])).to eq(%w[12 43])
    end
  end
end
