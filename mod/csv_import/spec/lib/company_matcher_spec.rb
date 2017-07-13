require_relative "../../lib/company_matcher"

describe CompanyMatcher do
  describe "#match" do
    def match company
      cm = CompanyMatcher.new(company)
      cm.match_name
    end

    it "finds exact match" do
      expect(match("Apple Inc")).to eq "Apple Inc."
    end

    context "empty company" do
      it "returns empty match" do
        expect(match("")).to eq ""
      end
    end

    it "maps Samsung" do
      expect(match("Samsung"))
        .to eq "Samsung"
    end

    it "maps Sony to Sony Corporation" do
      expect(match("Sony")).to eq "Sony Corporation"
    end

    it "maps Amazon" do
      expect(match("Amazon")).to eq "Amazon.com, Inc."
    end
  end

  describe "#match_type" do
    def match_type company_name
      CompanyMatcher.new(company_name).match_type
    end

    it "return none if empty" do
      expect(match_type("")).to eq :none
    end

    context "there is an exact match" do
      it "retursn :exact" do
        expect(match_type("Apple Inc")).to eq :exact
      end
    end
  end
end