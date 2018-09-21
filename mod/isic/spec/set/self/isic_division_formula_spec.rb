# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::IsicDivisionFormula do
  describe "get_value" do
    it "finds unique leading two digits" do
      expect(card_subject.get_value([%w[123 125 432]])).to eq(%w[12 43])
    end
  end
end
