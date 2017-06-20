describe OCCompany do
  let(:oc) {OCCompany.new("gb", "00102498")}

  context "when company identifier is valid" do
    it "has name" do
      expect(oc.name).to eq "BP P.L.C."
    end

    it "has previous names" do
      expect(oc.previous_names)
        .to include("BP AMOCO P.L.C.", "THE BRITISH PETROLEUM COMPANY P.L.C.")
    end

    it "has jurisdiction code" do
      expect(oc.jurisdiction_code).to eq "gb"
    end

    it "has registered address" do
      expect(oc.registered_address).to be_a String
    end

    it "has incorporation date" do
      expect(oc.incorporation_date).to be_a Date
      expect(oc.incorporation_date.year).to eq 1909
    end

    it "has company type" do
      expect(oc.company_type).to eq "Public Limited Company"
    end

    it "has status" do
      expect(oc.status).to eq "Active"
    end

    it "has url" do
      expect(oc.url).to eq "https://opencorporates.com/companies/gb/00102498"
    end

  end
end

