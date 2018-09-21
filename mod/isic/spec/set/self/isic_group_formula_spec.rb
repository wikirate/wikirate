# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::IsicGroupFormula do
  describe "get_value" do
    it "finds unique leading three digits" do
      expect(card_subject.get_value([%w[1234 1235 4321]])).to eq(%w[123 432])
    end
  end
end
