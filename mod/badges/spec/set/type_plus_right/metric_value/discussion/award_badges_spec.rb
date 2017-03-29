# -*- encoding : utf-8 -*-

require_relative "../../../../support/award_answer_badges_shared_examples"

describe Card::Set::TypePlusRight::MetricValue::Value::AwardBadges do
  describe "discuss badges" do
    let(:badge_action) { :discuss }
    let(:sample_acting_card) { sample_metric_value.field(:discussion, new: {}) }

    def execute_awarded_action count
      answer_card(count).field(:discussion, new: {})
                        .update_attributes! content: "comment"
    end

    context "reached bronze threshold" do
      it_behaves_like "answer badges", 1, "Commentator"
    end

    context "reached silver threshold" do
      it_behaves_like "answer badges", 2, "Commentary Team"
    end

    context "reached gold threshold" do
      it_behaves_like "answer badges", 3, "Expert Commentary"
    end
  end
end
