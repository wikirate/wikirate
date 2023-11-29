RSpec.describe Card::Set::TypePlusRight::Region::OcJurisdictionKey do
  context "validate_oc_key" do
    let(:oc_key) { Card["Argentina+OpenCorporates Jurisdiction key"] }

    it "fetches the right oc code." do
      expect(oc_key.content).to eq("ar")
    end

    it "does not allow duplicate oc_keys" do
      expect { oc_key.update! content: "zw" }
        .to raise_error /OC key already exists/
    end

    it "updates the oc key if it doesn't already exist" do
      expect {
        oc_key.update! content: "12"
      }.to change { oc_key.reload.content }.to eq("12")
    end

    it "does not update the oc key if the content is the same" do
      expect {
        oc_key.update! content: oc_key.content
      }.not_to change { oc_key.reload.content }
    end
  end
end
