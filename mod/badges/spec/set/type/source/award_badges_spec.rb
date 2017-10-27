# -*- encoding : utf-8 -*-

require_relative "../../../support/award_badges_shared_examples"

RSpec.describe Card::Set::Type::Source::AwardBadges do
  describe "discuss badges" do
    let(:badge_action) { :create }
    let(:badge_type) { :source }
    let(:sample_acting_card) { sample_source }

    def execute_awarded_action number
      Card.create!(
        type_id: Card::SourceID,
        subcards: {
          "+Link" => { content: "http://example.com/#{number}" }
        }
      )
    end

    context "reached bronze threshold" do
      it_behaves_like "award badges", 1, "Inside Source"
    end

    context "reached silver threshold" do
      it_behaves_like "award badges", 2, "A Cite to Behold"
    end

    context "reached gold threshold" do
      it_behaves_like "award badges", 3, "A Source of Inspiration"
    end
  end
end
