# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Metric::AwardBadges do
  let(:badge_action) { :create }
  let(:badge_type) { :metric }
  let(:sample_acting_card) { sample_metric }

  describe "create badges" do
    def execute_awarded_action number
      create_metric name: "Jedi+Metric #{number}",
                    type: :researched
    end

    context "when reached bronze threshold" do
      it_behaves_like "award badges", 1, "Metric Creator"
    end

    context "when reached silver threshold" do
      it_behaves_like "award badges", 2, "Metric Tonnes"
    end

    context "when reached gold threshold" do
      it_behaves_like "award badges", 3, "Research Agenda-Setter"
    end
  end
end
