# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::Answer::Discussion::AwardBadges do
  describe "discuss badges" do
    let(:badge_action) { :discuss }
    let(:sample_acting_card) { sample_answer.field(:discussion) }

    def execute_awarded_action count
      answer_card(count).field(:discussion)
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
