# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::IsicSectionFormula do
  # described_class not in scope :(
  let(:dummy_class) { Class.new { include Card::Set::Self::IsicSectionFormula } }

  describe "get_value" do
    it "finds unique section letter mapping" do
      expect(dummy_class.new.get_value([%w[64 65 99 50 49 68]])).to eq(%w[K U H L])
    end
  end

  describe "integration" do
    it "makes all the calculations between class and section" do
      create_answer metric: Card["OpenCorporates+Industry Class"], content: %w[0111 9609]
      section_answer = Answer.where(company_id: sample_company.id,
                                    metric_id: Card.fetch_id("ISIC+Industry Section"),
                                    year: 2015).take.card
      expect(section_answer.value_card.raw_value).to eq(%w[A S])
    end
  end
end
