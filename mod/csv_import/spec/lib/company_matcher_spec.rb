require_relative "../../lib/company_matcher"

RSpec.describe CompanyMatcher do
  describe "#match" do
    def match company
      cm = CompanyMatcher.new(company)
      cm.match_name
    end

    it "finds exact match" do
      expect(match("Apple Inc")).to eq "Apple Inc."
    end

    it "finds alias match" do
      expect(match("Alphabet")).to eq "Google Inc."
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

    it "maps Sony to Sony Group" do
      expect(match("Sony")).to eq "Sony Group"
    end

    it "maps Amazon to Amazon.com, Inc." do
      expect(match("Amazon")).to eq "Amazon.com, Inc."
    end
  end

  describe "#suggestion" do
    def match_type company_name
      CompanyMatcher.new(company_name).suggestion
    end

    example "original company if no match" do
      expect(match_type("Unknown Company")).to eq "Unknown Company"
    end

    example "name in db if exact match" do
      expect(match_type("Apple Inc")).to eq "Apple Inc."
    end

    example "name in db if partial match" do
      expect(match_type("Sony")).to eq "Sony Group"
    end

    example "name in db if alias match" do
      expect(match_type("Alphabet")).to eq "Google Inc."
    end
  end

  describe "#match_type" do
    def match_type company_name
      CompanyMatcher.new(company_name).match_type
    end

    it "returns none if empty" do
      expect(match_type("")).to eq :none
    end

    it "no match" do
      expect(match_type("Unknown Company")).to eq :none
    end

    example "exact match" do
      expect(match_type("Apple Inc")).to eq :exact
    end

    example "partial match" do
      expect(match_type("Sony")).to eq :partial
    end

    example "alias match" do
      expect(match_type("Alphabet")).to eq :alias
    end
  end
end
