RSpec.describe Card::Set::Type::AnswerImport do
  describe "import!" do
    let(:import_item_class) { Card::AnswerImportItem }
    let(:import_card) { :answer_import_test.card }
    let(:status) { import_card.import_status_card.status }

    def import_ready_items
      import_card.import! status.status_indices(:ready)
    end

    it "imports specified rows" do
      expect(status.count(:ready)).to be_positive
      expect(status.count(:success)).to be_zero

      import_ready_items

      status = import_card.import_status_card.refresh(true).status
      expect(status.count(:ready)).to be_zero
      expect(status.count(:success)).to be_positive
    end

    # FIXME: I think this one isn't getting marked because it already exists?
    xit "marks value in answer table as imported" do
      import_ready_items
      answer_id = status.item_hash(status.status_indices(:imported).first)[:id]
      answer = Answer.for_card(answer_id)
      expect(answer.route).to eq(Answer.route_index(:import))
    end
  end
end
