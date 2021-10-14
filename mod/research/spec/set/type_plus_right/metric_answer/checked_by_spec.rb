RSpec.describe Card::Set::TypePlusRight::MetricAnswer::CheckedBy do
  let(:researched_card) { Card["Jedi+deadliness+Death_Star+1977"] }
  let(:researched_card_2) { Card["Jedi+disturbances in the force+Death_Star+1977"] }
  let(:wikirating_card) { Card.fetch "Jedi+darkness_rating+Death_Star+1977" }

  def level symbol
    Answer.verification_index symbol
  end

  describe "wikirating verification" do
    it "starts as a 1 (unverified)" do
      expect(wikirating_card.answer.verification).to eq(level(:community_added))
    end

    context "when one (not all) dependee researched card's verification changes" do
      it "lowers to 0 (flagged) if flagged" do
        researched_card.checked_by_card.update! content: "request"
        expect(researched_card.answer.verification).to eq(level(:flagged))
        expect(wikirating_card.answer.verification).to eq(level(:flagged))
      end

      it "stays 1 (unverified) if verified" do
        check_answer researched_card
        expect(researched_card.answer.verification).to eq(level(:community_verified))
        expect(wikirating_card.answer.verification).to eq(level(:community_added))
      end
    end

    context "when all dependee research cards are verified" do
      it "raises to 2" do
        check_answer researched_card
        check_answer researched_card_2
        expect(researched_card.answer.verification).to eq(level(:community_verified))
        expect(wikirating_card.answer.verification).to eq(level(:community_verified))
      end
    end
  end
end
