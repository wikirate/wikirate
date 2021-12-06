RSpec.describe Card::Set::Right::CheckedBy do
  let(:answer_card) { Card["joe_user+RM+death_star+1977"] }

  describe "check value" do
    before do
      check_answer answer_card
    end

    let(:checked_by) do
      answer_card.fetch :checked_by
    end

    it "checks the metric value" do
      expect(checked_by.item_names.size).to eq(1)
      expect(checked_by.item_names).to include("Joe User")
    end

    it "updates the answers table" do
      expect(answer_card.answer.checkers).to eq("Joe User")
    end

    context "value updated" do
      before do
        answer_card.value_card.update content: "200"
      end

      it "clears checked by status" do
        expect(checked_by.content).to eq ""
      end
    end
  end

  describe "uncheck value" do
    subject(:cb_card) do
      cb_card = answer_card.fetch :checked_by, new: { content: "Joe User" }
      cb_card.save!
      cb_card.clear_subcards
      cb_card.update! trigger: :drop_check
      cb_card
    end

    it "checks the metric value" do
      expect(cb_card.item_names.size).to eq(0)
    end

    it "updates the answers table" do
      expect(answer_card.answer.checkers).to eq(nil)
    end
  end
end
