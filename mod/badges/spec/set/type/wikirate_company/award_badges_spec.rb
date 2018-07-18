# -*- encoding : utf-8 -*-

require_relative "../../../support/award_badges_shared_examples"

describe Card::Set::Type::WikirateCompany::AwardBadges do
  let(:badge_action) { :create }
  let(:badge_type) { :wikirate_company }
  let(:sample_acting_card) { sample_company }

  describe "create badges" do
    def execute_awarded_action number
      Card.create! type_id: Card::WikirateCompanyID,
                   name: "Company #{number}"
    end

    context "when reached bronze threshold" do
      it_behaves_like "award badges", 1, "Company Register"
    end

    context "when reached silver threshold" do
      it_behaves_like "award badges", 2, "The Company Store"
    end

    context "when reached gold threshold" do
      it_behaves_like "award badges", 3, "Companies (in the) House"
    end
  end
end
