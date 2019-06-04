# -*- encoding : utf-8 -*-

require_relative "../../../support/award_badges_shared_examples"

RSpec.describe Card::Set::Type::Source::AwardBadges do
  describe "discuss badges" do
    let(:badge_action) { :create }
    let(:badge_type) { :source }
    let(:sample_acting_card) { sample_source }

    def execute_awarded_action number
      create_source "http://www.google.com/?q=source-#{number}"
    end

    context "when reached bronze threshold" do
      it_behaves_like "award badges", 1, "Inside Source"
    end

    context "when reached silver threshold" do
      it_behaves_like "award badges", 2, "A Cite to Behold"
    end

    context "when reached gold threshold" do
      it_behaves_like "award badges", 3, "A Source of Inspiration"
    end
  end
end
