# -*- encoding : utf-8 -*-

describe Card::Set::Right::BadgesEarned do
  let(:card) do
    Card.fetch "John User", :metric_value, :badges_earned,
               new: { type: "Pointer" }
  end
  before do
    card.update_attributes!(
      content: ["Researcher",
                "Commentator",
                "Death Star+Researcher+company badge",
                "Death Star+Research Engine+company badge",
                "Answer Advancer",
                "Answer Enhancer",
                "Research Engine",
                "Evil Project+Researcher+project badge",
                "Research Fellow"].to_pointer_content
    )
  end

  describe "#ordered_badge_cards" do
    subject { card.ordered_badge_cards.map(&:name) }
    it "has correct order" do
      is_expected.to eq ["Research Fellow",
                         "Research Engine",
                         "Death Star+Research Engine+company badge",
                         "Researcher",
                         "Evil Project+Researcher+project badge",
                         "Death Star+Researcher+company badge",
                         "Answer Enhancer",
                         "Answer Advancer",
                         "Commentator"]
    end
  end

  describe "html format" do
    describe "view :core" do
      #it
    end
  end
end
