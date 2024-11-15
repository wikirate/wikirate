# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::Record::CheckedBy::AwardBadges do
  describe "check badges" do
    let(:badge_action) { :check }
    let(:sample_acting_card) { sample_record.field(:checked_by) }

    def execute_awarded_action count
      record_card(count).field(:checked_by)
                        .update! content: "[[John]]"
    end

    context "when reached bronze threshold" do
      it_behaves_like "record badges", 1, "Checker"
    end

    context "when reached silver threshold" do
      it_behaves_like "record badges", 2, "Check Pro"
    end

    context "when reached gold threshold" do
      it_behaves_like "record badges", 3, "Check Mate"
    end
  end
end
