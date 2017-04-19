# -*- encoding : utf-8 -*-

require_relative "../../../../support/award_badges_shared_examples"

describe Card::Set::TypePlusRight::Project::Discussion::AwardBadges do
  describe "discuss badges" do
    let(:badge_action) { :discuss }
    let(:badge_type) { :project }
    let(:sample_acting_card) { sample_project.field(:discussion, new: {}) }

    def execute_awarded_action number
      Card::Auth.as_bot do
        project = Card.create! type_id: Card::ProjectID,
                               name: "Project #{number}"
        Card.create! name: "#{project.name}+discussion"
      end
    end

    context "reached bronze threshold" do
      it_behaves_like "award badges", 2, "Project Q&#38;A"
    end
  end
end
