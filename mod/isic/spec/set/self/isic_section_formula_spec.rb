# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::IsicSectionFormula do
  describe "compute" do
    it "finds unique section letter mapping" do
      expect(Card[:isic_section_formula].calculator.compute([%w[64 65 99 50 49 68]]))
        .to eq(%w[K U H L])
    end
  end

  describe "integration" do
    it "makes all the calculations between class and section" do
      create_answer metric: "OpenCorporates+Industry Class",
                    value: %w[0111 9609],
                    user: "Joe Admin"
      section_answer = Answer.where(company_id: sample_company.id,
                                    metric_id: "ISIC+Industry Section".card_id,
                                    year: 2015).take.card
      expect(section_answer.value_card.raw_value).to eq(%w[A S])
    end
  end
end
