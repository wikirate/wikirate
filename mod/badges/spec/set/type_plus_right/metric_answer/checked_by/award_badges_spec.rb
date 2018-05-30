# -*- encoding : utf-8 -*-

require_relative "../../../../support/award_answer_badges_shared_examples"

RSpec.describe Card::Set::TypePlusRight::MetricAnswer::CheckedBy::AwardBadges do
  describe "check badges" do
    let(:badge_action) { :check }
    let(:sample_acting_card) { sample_metric_answer.field(:checked_by, new: {}) }

    def execute_awarded_action count
      answer_card(count).field(:checked_by, new: {})
                        .update_attributes! content: "[[John]]"
    end

    context "reached bronze threshold" do
      it_behaves_like "answer badges", 1, "Checker"
    end

    context "reached silver threshold" do
      it_behaves_like "answer badges", 2, "Check Pro"
    end

    context "reached gold threshold" do
      it_behaves_like "answer badges", 3, "Check Mate"
    end
  end
end
