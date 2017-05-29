# -*- encoding : utf-8 -*-

require_relative "../../../../support/award_badges_shared_examples"

describe Card::Set::TypePlusRight::WikirateCompany::Image::AwardBadges do
  describe "logo badges" do
    let(:badge_action) { :logo }
    let(:badge_type) { :wikirate_company }
    let(:sample_acting_card) { sample_company.field(:image, new: {}) }

    def execute_awarded_action number
      company = nil
      Card::Auth.as_bot do
        company = Card.create! type_id: Card::WikirateCompanyID,
                               name: "Company #{number}"
      end
      Card::Auth.as_bot do
        Card.create! name: "#{company.name}+image", type_id: Card::BasicID
      end
    end

    context "reached bronze threshold" do
      it_behaves_like "award badges", 1, "Logo Adder"
    end

    context "reached silver threshold" do
      it_behaves_like "award badges", 2, "How Lo can you Go"
    end

    context "reached gold threshold" do
      it_behaves_like "award badges", 3, "Logo and Behold"
    end
  end
end
