# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::IsicGroupFormula do
  # described_class not in scope :(
  let(:dummy_class) { Class.new { include Card::Set::Self::IsicGroupFormula } }

  describe "get_value" do
    it "finds unique leading three digits" do
      expect(dummy_class.new.get_value([%w[1234 1235 4321]])).to eq(%w[123 432])
    end
  end
end
