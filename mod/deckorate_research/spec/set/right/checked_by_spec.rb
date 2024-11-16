RSpec.describe Card::Set::Right::CheckedBy do
  let(:record_card) { Card["joe_user+RM+death_star+1977"] }
  let(:checked_by_card) { record_card.fetch :checked_by }

  describe "check value" do
    before { check_record record_card }

    it "checks the metric value" do
      expect(checked_by_card.item_names.size).to eq(1)
      expect(checked_by_card.item_names).to include("Joe User")
    end

    it "updates the records table" do
      expect(record_card.record.checkers).to eq("Joe User")
    end

    context "value updated" do
      before do
        record_card.value_card.update content: "200"
      end

      it "clears checked by status" do
        expect(checked_by_card.content).to eq ""
      end
    end
  end

  context "with checked card" do
    let(:record_card) { Card["Joe User+big single+Sony Corporation+2005"] }

    it "is confirmed to be checked" do
      expect(checked_by_card.item_names).to eq(["Joe User"])
    end

    describe "unconfirm value via drop check" do
      before { checked_by_card.update! trigger: :drop_check }

      it "unchecks the metric value" do
        expect(checked_by_card.item_names.size).to eq(0)
      end

      it "updates the records table" do
        expect(record_card.record.checkers).to eq(nil)
      end
    end

    describe "uncheck value via delete" do
      it "updates the lookup table", as_bot: true do
        expect(record_card.record.verification).to eq(3)
        checked_by_card.delete!
        lookup = record_card.record
        expect(lookup.checkers).to eq(nil)
        expect(lookup.verification).to eq(3)
      end
    end
  end
end
