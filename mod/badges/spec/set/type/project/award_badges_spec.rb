# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Project::AwardBadges do
  let(:badge_action) { :create }
  let(:badge_type) { :project }
  let(:sample_acting_card) { sample_dataset }

  describe "create badges" do
    def execute_awarded_action number
      Card.create! type_id: Card::ProjectID,
                   name: "Project #{number}"
    end

    context "when reached silver threshold" do
      it_behaves_like "award badges", 2, "Project Launcher"
    end
  end
end
