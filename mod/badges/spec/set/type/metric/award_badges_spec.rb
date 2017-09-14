# -*- encoding : utf-8 -*-

require_relative "../../../support/award_badges_shared_examples"

describe Card::Set::Type::Metric::AwardBadges do
  let(:badge_action) { :create }
  let(:badge_type) { :metric }
  let(:sample_acting_card) { sample_metric }

  describe "create badges" do
    def execute_awarded_action number
      Card::Metric.create name: "Jedi+Metric #{number}",
                          type: :researched
    end

    context "reached bronze threshold" do
      it_behaves_like "award badges", 1, "Metric Creator"
    end

    context "reached silver threshold" do
      it_behaves_like "award badges", 2, "Metric Tonnes"
    end

    context "reached gold threshold" do
      it_behaves_like "award badges", 3, "Research Agenda-Setter"
    end
  end
end
