RSpec.describe Card::AnswerQuery::AdvancedFilters do
  include_context "answer query"

  let(:answer_parts) { [2] } # return company names
  let :default_filters do
    { metric_id: "Jedi+disturbances in the Force".card_id, year: :latest }
  end

  describe "#company_answer_query" do
    it "finds companies with metric" do
      expect(search(company_answer: { metric_id: "Joe User+RM".card_id }))
        .to eq(["Death Star"])
    end
  end

  describe "#answer_query" do
    it "finds companies with metric" do
      expect(search(answer: { metric_id: "Joe User+RM".card_id }))
        .to eq(["Death Star"])
    end
  end
end
