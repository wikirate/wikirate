# -*- encoding : utf-8 -*-

require_relative "../../../../support/award_badges_shared_examples"

RSpec.describe Card::Set::TypePlusRight::User::Bookmark::AwardBadges do
  describe "bookmark badges" do
    let(:badge_action) { :bookmark }
    let(:badge_type) { :metric }
    let(:sample_acting_card) { Card::Auth.current.bookmarks_card }

    def execute_awarded_action number
      Card::Auth.as_bot do
        sample_acting_card.add_item! "Joe User+researched number #{number}"
      end
    end

    context "when reached bronze threshold" do
      it_behaves_like "award badges", 1, "Metric Bookmarker"
    end
    context "when reached silver threshold" do
      it_behaves_like "award badges", 2, "Metric Critic"
    end
    context "when reached gold threshold" do
      it_behaves_like "award badges", 3, "Metric Connoisseur"
    end
  end
end
