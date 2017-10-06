require_relative "../../../support/shared_answer_csv_row"

RSpec.describe Card::Set::Abstract::Import::ExecuteImport do
  let(:card) { Card["A"].with_set(described_class) }
  describe "#data_import?" do
    subject { card.data_import? }

    example "no data given" do
      is_expected.to be_falsey
    end

    example "an empty hash given" do
      Card::Env.params[:import_rows] = {}
      is_expected.to be_falsey
    end

    example "an import value" do
      Card::Env.params[:import_rows] = { 1 => true }
      is_expected.to be_truthy
    end
  end

  describe "event: execute_import" do
    include_context "answer csv row"

    before do
      allow(card).to receive(:valid_import_data?).and_return(true)
      allow(card).to receive(:data_import?).and_return(true)
    end

    it "imports single row" do
      import answer_row
      expect(Card[answer_name]).to be_a Card
    end

    it "imports two rows" do
      import answer_row, answer_row(year: "2005")
      expect(Card[answer_name]).to be_a Card
      expect(Card[answer_name(year: "2005")]).to be_a Card
    end

    it "corrects company" do
      import [answer_row, { company: "Alphabet" }, match_type: :none]
      expect(Card["Alphabet"]).to have_type :wikirate_company
      expect(Card[answer_name(company: "Alphabet")]).to be_a Card
    end
  end
end
