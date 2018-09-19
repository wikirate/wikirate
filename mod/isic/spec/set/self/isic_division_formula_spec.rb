# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::IsicDivisionFormula do
  # described_class not in scope :(
  let(:dummy_class) { Class.new { include Card::Set::Self::IsicDivisionFormula } }

  describe "get_value" do
    it "finds unique leading two digits" do
      expect(dummy_class.new.get_value([%w[123 125 432]])).to eq(%w[12 43])
    end
  end
end
