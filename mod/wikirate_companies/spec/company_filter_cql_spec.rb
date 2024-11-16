RSpec.describe Card::CompanyFilterCql do
  describe "CQL extensions" do
    specify "company_record" do
      results = Card.search company_record: [{ year: "latest",
                                               metric_id: "Joe User+RM".card_id }]
      expect(results.map(&:name).sort).to eq(["Apple Inc.", "Death Star"])
    end
  end
end
