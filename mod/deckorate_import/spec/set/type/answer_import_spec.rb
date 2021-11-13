RSpec.describe Card::Set::Type::AnswerImport do
  describe "import!" do
    let(:import_item_class) { Card::AnswerImportItem }
    let(:import_card) { Card["answer import test"] }
    let(:status) { import_card.import_status_card.status }

    def import_ready_items
      import_card.import! status.status_indeces(:ready)
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
      answer_id = status.item_hash(status.status_indeces(:imported).first)[:id]
      answer = Answer.for_card(answer_id)
      expect(answer.imported).to eq true
    end
  end
end
