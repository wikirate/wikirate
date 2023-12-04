RSpec.describe Card::Set::TypePlusRight::Region::CountryCode do
  def card_subject
    Card["Argentina+Country Code"]
  end

  let(:country_code) { card_subject }

  context "when validation of country codes" do
    it "fetches the right country code." do
      expect(country_code.content).to eq("AR")
    end

    it "does not allow duplicate country codes" do
      expect { country_code.update! content: "ZW" }
        .to raise_error /Country Code already exists/
    end

    it "updates the country code if it doesn't already exist" do
      expect do
        country_code.update! content: "12"
      end.to(change { country_code.reload.content }.to("12"))
    end

    it "does not update the country code if the content is the same" do
      expect do
        country_code.update! content: country_code.content
      end.not_to(change { country_code.reload.content })
    end
  end
end
