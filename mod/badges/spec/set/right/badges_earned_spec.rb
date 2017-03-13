# -*- encoding : utf-8 -*-

require_relative "../../support/badge_count_shared_examples.rb"

describe Card::Set::Right::BadgesEarned do
  let(:card) do
    Card.fetch "Joe Camel", :metric_value, :badges_earned, new: {}
  end

  before do
    Card::Auth.as_bot do
    card.update_attributes!(
      content: ["Research Fellow",
                "Research Engine",
                "Death Star+Research Engine+company badge",
                "Researcher",
                "Evil Project+Researcher+project badge",
                "Death Star+Researcher+company badge",
                "Answer Enhancer",
                "Answer Advancer",
                "Commentator"].to_pointer_content
    )
    end
  end

  describe "#ordered_badge_cards" do
    subject { card.ordered_badge_cards.map(&:name) }
    it "has correct order" do
      expect([subject.delete_at(4), subject.delete_at(4)])
        .to contain_exactly "Evil Project+Researcher+project badge",
                            "Death Star+Researcher+company badge"
      is_expected.to eq ["Research Fellow",
                         "Research Engine",
                         "Death Star+Research Engine+company badge",
                         "Researcher",
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

  it_behaves_like "badge count", 9, 5, 3, 1 do
    def badge_count level=nil
      card.badge_count level
    end
  end
end
