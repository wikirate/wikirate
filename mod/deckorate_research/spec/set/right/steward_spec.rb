RSpec.describe Card::Set::Right::Steward do
  let(:metric) { Card["Jedi+deadliness"] }
  let(:metric_2) { Card["Jedi+disturbances in the Force"] }
  let(:researched_card) { Card["Jedi+deadliness+Death_Star+1977"] }
  let(:wikirating_card) { Card.fetch "Jedi+darkness_rating+Death_Star+1977" }

  def level symbol
    ::Answer.verification_index symbol
  end

  describe "updating stewards" do
    it "starts with community added metrics" do
      expect(researched_card.answer.verification).to eq(level(:unverified))
      expect(wikirating_card.answer.verification).to eq(level(:unverified))
    end

    it "updates researched (not wikirating) when one metric steward updated" do
      metric.stewarded_card.update! content: "Decko Bot"
      expect(researched_card.answer.verification).to eq(level(:steward_verified))
      expect(wikirating_card.answer.verification).to eq(level(:unverified))
    end

    it "updates researched and wikirating when all metric stewards updated" do
      metric.stewarded_card.update! content: "Decko Bot"
      metric_2.stewarded_card.update! content: "Decko Bot"
      expect(researched_card.answer.verification).to eq(level(:steward_verified))
      expect(wikirating_card.answer.verification).to eq(level(:steward_verified))
    end
  end
end
