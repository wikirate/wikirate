RSpec.describe Card::Set::Type::Region do
  describe "validate_region_identifier" do
    let(:region) { Card["Argentina"] }

    it "fetches the right oc code." do
      expect(region.oc_code).to eq(:ar)
    end
  end
end
