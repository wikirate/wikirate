RSpec.describe Card::CompanyFilterCql do
  describe "CQL extensions" do
    specify "company_answer" do
      results = Card.search company_answer: [{ year: "latest",
                                               metric_id: "Joe User+RM".card_id }]
      expect(results.map(&:name).sort).to eq(["Apple Inc.", "Death Star"])
    end
  end
end
