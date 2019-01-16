# -*- encoding : utf-8 -*-

require_relative "../../../../support/award_answer_badges_shared_examples"

describe Card::Set::TypePlusRight::MetricAnswer::Value::AwardBadges do
  describe "discuss badges" do
    let(:badge_action) { :discuss }
    let(:sample_acting_card) { sample_metric_answer.field(:discussion, new: {}) }

    def execute_awarded_action count
      answer_card(count).field(:discussion, new: {})
                        .update! content: "comment"
    end

    context "when reached bronze threshold" do
      it_behaves_like "answer badges", 1, "Commentator"
    end

    context "when reached silver threshold" do
      it_behaves_like "answer badges", 2, "Commentary Team"
    end

    context "when reached gold threshold" do
      it_behaves_like "answer badges", 3, "Expert Commentary"
    end
  end
end
