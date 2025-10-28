# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::Company::Image::AwardBadges do
  describe "logo badges" do
    let(:badge_action) { :logo }
    let(:badge_type) { :company }
    let(:sample_acting_card) { sample_company.field :image }

    def execute_awarded_action number
      company = nil
      Card::Auth.as_bot do
        company = Card.create! type_id: Card::CompanyID,
                               name: "Company #{number}"
      end
      Card::Auth.as_bot do
        Card.create! name: "#{company.name}+image", type_id: Card::BasicID
      end
    end

    context "when reached bronze threshold" do
      it_behaves_like "award badges", 1, "Logo Adder"
    end

    context "when reached silver threshold" do
      it_behaves_like "award badges", 2, "How Lo can you Go"
    end

    context "when reached gold threshold" do
      it_behaves_like "award badges", 3, "Logo and Behold"
    end
  end
end
