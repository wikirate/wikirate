RSpec.describe Card::Set::TypePlusRight::MetricAnswer::CheckedBy do
  let(:researched_card) { Card["Jedi+deadliness+Death_Star+1977"]}
  let(:wikirating_card) { Card.fetch "Jedi+darkness_rating+Death_Star+1977" }

  describe "wikirating verification" do
    it "starts as a 1 (unverified)" do
      expect(wikirating_card.verification).to eq(1)
    end

    context "when one researched card is flagged" do
      it "lowers to 0 (flagged) if researched card is flagged" do
        researched_card.checked_by_card.update! content: "request"
        expect(researched_card.verification).to eq(0)
        expect(wikirating_card.verification).to eq(0)
      end
    end
  end
end
