# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::IsicGroupFormula do
  describe "compute" do
    it "finds unique leading three digits" do
      expect(Card[:isic_group_formula].calculator.compute([%w[1234 1235 4321]]))
        .to eq(%w[123 432])
    end
  end
end
