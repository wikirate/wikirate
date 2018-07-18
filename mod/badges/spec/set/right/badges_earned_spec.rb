# -*- encoding : utf-8 -*-

require_relative "../../support/badge_count_shared_examples.rb"

describe Card::Set::Right::BadgesEarned do
  let(:card) do
    Card.fetch "Joe Camel", :metric_answer, :badges_earned, new: {}
  end

  let(:badges) do
    ["Evil Project+Researcher+project badge",
     "Answer Enhancer",
     "Research Master",
     "Commentator",
     "Death Star+Research Pro+company badge",
     "Researcher",
     "Death Star+Researcher+company badge",
     "Answer Advancer",
     "Research Pro"]
  end

  let(:ordered_badges) do
    ["Answer Advancer",
     "Research Master",
     "Answer Enhancer",
     "Research Pro",
     "Death Star+Research Pro+company badge",
     "Commentator",
     "Researcher"]
  end

  describe "#ordered_badge_cards" do
    before do
      Card::Auth.as_bot do
        card.update_attributes!(
          content: badges.to_pointer_content
        )
      end
    end

    subject { card.ordered_badge_cards.map(&:name) }

    it "has correct order" do
      expect([subject.delete_at(7), subject.delete_at(7)])
        .to contain_exactly "Evil Project+Researcher+project badge",
                            "Death Star+Researcher+company badge"
      is_expected.to eq ordered_badges
    end

    it_behaves_like "badge count", 9, 4, 3, 2 do
      def badge_count level=nil
        card.badge_count level
      end
    end
  end

  describe "#add_badge" do
    before do
      Card::Auth.as_bot do
        card.db_content = ""
        badges.each do |name|
          card.add_badge_card Card.fetch(name)
          card.save!
        end
      end
    end

    subject { card.item_names }

    it "adds badge in the right order order" do
      expect([subject.delete_at(7), subject.delete_at(7)])
        .to contain_exactly "Evil Project+Researcher+project badge",
                            "Death Star+Researcher+company badge"
      is_expected.to eq ordered_badges
    end
  end

  describe "html format" do
    describe "view :core" do
      # it
    end
  end
end
