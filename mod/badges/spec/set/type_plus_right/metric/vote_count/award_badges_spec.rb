# -*- encoding : utf-8 -*-

require_relative "../../../../support/award_badges_shared_examples"

describe Card::Set::TypePlusRight::Metric::VoteCount::AwardBadges do
  describe "vote badges" do
    let(:badge_action) { :vote }
    let(:badge_type) { :metric }
    let(:sample_acting_card) { sample_metric.field(:vote_count, new: {}) }

    def execute_awarded_action number
      Card::Auth.as_bot do
        vote_card = Card["Joe User+researched number #{number}"].vote_count_card
        if number.even?
          vote_card.vote_up
        else
          vote_card.vote_down
        end
        vote_card.save!
      end
    end

    context "reached bronze threshold" do
      it_behaves_like "award badges", 1, "Metric Voter"
    end
    context "reached silver threshold" do
      it_behaves_like "award badges", 2, "Metric Critic"
    end
    context "reached gold threshold" do
      it_behaves_like "award badges", 3, "Metric Connoisseur"
    end
  end
end
