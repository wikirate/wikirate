# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::MetricAnswer::CheckedBy::AwardBadges do
  describe "check badges" do
    let(:badge_action) { :check }
    let(:sample_acting_card) { sample_answer.subfield(:checked_by) }

    def execute_awarded_action count
      answer_card(count).subfield(:checked_by)
                        .update! content: "[[John]]"
    end

    context "when reached bronze threshold" do
      it_behaves_like "answer badges", 1, "Checker"
    end

    context "when reached silver threshold" do
      it_behaves_like "answer badges", 2, "Check Pro"
    end

    context "when reached gold threshold" do
      it_behaves_like "answer badges", 3, "Check Mate"
    end
  end
end
