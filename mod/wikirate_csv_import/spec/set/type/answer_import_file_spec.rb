require_relative "../../support/shared_csv_import"
require_relative "../../support/shared_answer_import_examples"

RSpec.describe Card::Set::Type::AnswerImportFile, type: :controller do
  describe "answer csv import" do
    let(:import_item_class) { AnswerImportItem }
    let(:import_card) { Card["answer import test"] }
    def status
      import_card.import_status_card.status
    end


    it "imports specified rows" do
      expect(status.count(:ready)).to be_positive
      expect(status.count(:success)).to be_zero

      import_card.import! status.status_indeces(:ready)

      expect(status.count(:ready)).to be_zero
      expect(status.count(:success)).to be_positive
    end



    include_context "csv import" do

      include_examples "answer import examples" do
        let(:import_file_type_id) { Card::AnswerImportFileID }
        let(:attachment_name) { :answer_import_file }
        let(:import_file_name) { "test" }
        let(:unordered_import_file_name) { "wrong_order_with_headers" }
      end

      it "imports comment" do
        trigger_import :exact_match
        expect(Card[answer_name(:exact_match), :discussion]).to have_db_content(/chch/)
      end

      it "marks value in answer table as imported" do
        trigger_import :exact_match
        answer_id = answer_card(:exact_match).id
        answer = Answer.find_by_answer_id(answer_id)
        expect(answer.imported).to eq true
      end
    end
  end
end
