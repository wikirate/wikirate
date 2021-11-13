RSpec.describe Card::Set::Type::WikirateCompany do
  subject do
    Card::Query.run @query.reverse_merge(return: :name, sort: :name)
  end

  describe "fulltext_match: value" do
    it "matches on search_content" do
      @query = { fulltext_match: "Alphabet", type: "Company" }
      is_expected.to eq(["Google LLC"])
    end

    it "doesn't allow word fragments" do
      @query = { fulltext_match: "gle i", type: "Company" }
      is_expected.to eq([])
    end

    it "switches to sql regexp if preceeded by a ~" do
      @query = { fulltext_match: "~ gle i", type: "Company" }
      is_expected.to eq(["Google Inc."])
    end
  end
end
