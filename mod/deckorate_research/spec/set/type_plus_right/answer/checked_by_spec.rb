RSpec.describe Card::Set::TypePlusRight::Answer::CheckedBy do
  include Cardio::FlagSpecHelper

  let(:researched_card) { Card["Jedi+deadliness+Death_Star+1977"] }
  let(:researched_card_2) { Card["Jedi+disturbances in the force+Death_Star+1977"] }
  let(:wikirating_card) { Card.fetch "Jedi+darkness_rating+Death_Star+1977" }

  def level symbol
    ::Answer.verification_index symbol
  end

  describe "wikirating verification" do
    it "starts as a 1 (unverified)" do
      expect(wikirating_card.answer.verification).to eq(level(:unverified))
    end

    context "when a dependee researched card's verification changes" do
      it "lowers to 0 (flagged) if flagged" do
        flag_subject researched_card.name
        expect(researched_card.answer.verification).to eq(level(:flagged))
        expect(wikirating_card.answer.verification).to eq(level(:flagged))
      end

      it "stays 1 (unverified) if verified" do
        check_answer researched_card
        expect(researched_card.answer.verification).to eq(level(:community_verified))
        expect(wikirating_card.answer.verification).to eq(level(:unverified))
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

  describe "research verification" do
    it "removes checker when flagged" do
      check_answer researched_card
      expect(researched_card.checked_by_card.first_name).to eq("Joe User")

      flag_subject researched_card.name
      expect(researched_card.checked_by_card.first_name).to be_blank
    end
  end
end
