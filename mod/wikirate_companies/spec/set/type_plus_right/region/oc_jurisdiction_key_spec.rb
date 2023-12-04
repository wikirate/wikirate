RSpec.describe Card::Set::TypePlusRight::Region::OcJurisdictionKey do
  def card_subject
    Card["Argentina+OpenCorporates Jurisdiction key"]
  end

  let(:oc_key) { card_subject }

  context "when validation of oc keys" do
    it "fetches the right oc key." do
      expect(oc_key.content).to eq("ar")
    end

    it "does not allow duplicate oc keys" do
      expect { oc_key.update! content: "zw" }
        .to raise_error /Open Corporates key already exists/
    end

    it "updates the oc key if it doesn't already exist" do
      expect do
        oc_key.update! content: "12"
      end.to(change { oc_key.reload.content }.to("12"))
    end

    it "does not update the oc key if the content is the same" do
      expect do
        oc_key.update! content: oc_key.content
      end.not_to(change { oc_key.reload.content })
    end
  end
end
