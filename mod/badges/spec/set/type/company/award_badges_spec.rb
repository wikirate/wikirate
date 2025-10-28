# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Company::AwardBadges do
  let(:badge_action) { :create }
  let(:badge_type) { :company }
  let(:sample_acting_card) { sample_company }

  describe "create badges" do
    def execute_awarded_action number
      Card.create! type: :company,
                   name: "Company #{number}",
                   fields: { headquarters: "Togo" }
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
