require_relative "../../../lib/open_corporates/api"

describe OpenCorporates::Company do
  context "when company identifier is valid" do
    before(:context) do
      @oc = described_class.new "gb", "00102498"
    end

    it "has name" do
      expect(@oc.name).to eq "BP P.L.C."
    end

    it "has previous names" do
      expect(@oc.previous_names)
        .to include("BP AMOCO P.L.C.", "THE BRITISH PETROLEUM COMPANY P.L.C.")
    end

    it "has jurisdiction code" do
      expect(@oc.jurisdiction_code).to eq "gb"
    end

    it "has registered address" do
      expect(@oc.registered_address).to be_a String
    end

    it "has incorporation date" do
      expect(@oc.incorporation_date).to be_a Date
      expect(@oc.incorporation_date.year).to eq 1909
    end

    it "has company type" do
      expect(@oc.company_type).to eq "Public Limited Company"
    end

    it "has status" do
      expect(@oc.status).to eq "Active"
    end

    it "has url" do
      expect(@oc.opencorporates_url).to eq "https://opencorporates.com/companies/gb/00102498"
    end
  end

  context "when api is not available" do
    let(:oc)  { described_class.new "gb", "00102498" }

    it "is invalid" do
      stub_const("OpenCorporates::API::HOST", "open-corporates-is-down.org")
      expect(oc.valid?).to eq false
    end

    it "has error" do
      stub_const("OpenCorporates::API::HOST", "open-corporates-is-down.org")
      expect(oc.error).to eq "service temporarily not available"
    end
  end

  context "when company number doesn't exit" do
    let(:oc)  { described_class.new "gb", "98" }

    it "is invalid" do
      expect(oc.valid?).to eq false
    end

    it "has error" do
      expect(oc.error).to eq "couldn't receive open corporates entry: Record not found"
    end
  end

  context "when jurisdiction code is invalid" do
    let(:oc)  { described_class.new "gbdbd", "00102498" }

    it "is invalid" do
      expect(oc.valid?).to eq false
    end

    it "has error" do
      expect(oc.error).to eq "couldn't receive open corporates entry: Record not found"
    end
  end
end

