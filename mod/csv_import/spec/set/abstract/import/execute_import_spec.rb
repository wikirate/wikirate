require_relative "../../../support/shared_csv_data"

describe Card::Set::Abstract::Import::ExecuteImport do
  let(:card) { Card["A"].with_set(described_class) }
  describe "#data_import?" do
    subject { card.data_import? }

    example "no data given" do
      is_expected.to be_falsey
    end

    example "an empty hash given" do
      Card::Env.params[:import_data] = {}
      is_expected.to be_falsey
    end

    example "an import value" do
      Card::Env.params[:import_data] = { 1 => { import: true } }
      is_expected.to be_truthy
    end
  end

  describe "event: execute_import" do
    include_context "csv data"

    before do
      allow(card).to receive(:valid_import_data?).and_return(true)
      allow(card).to receive(:data_import?).and_return(true)
    end

    it "imports single row" do
      import answer_data
      expect(Card[answer_name]).to be_a Card
    end

    it "imports two rows" do
      import answer_data, answer_data(year: "2005")
      expect(Card[answer_name]).to be_a Card
      expect(Card[answer_name(year: "2005")]).to be_a Card
    end

    it "corrects company" do
      import [answer_data, { company: "Alphabet" }, match_type: :none]
      expect(Card["Alphabet"]).to have_type :wikirate_company
      expect(Card[answer_name(company: "Alphabet")]).to be_a Card
    end

    def import *import_data
      csv_rows = import_data.map.with_index do |row_args, index|
        case row_args
        when Hash
          CSVRow::Structure::AnswerCSV.new row_args, index
        when Array
          row_hash, correction, extra_data = row_args
          CSVRow::Structure::AnswerCSV.new row_hash, index, correction, extra_data
        end

      end
      import_csv_rows *csv_rows
    end

    def import_csv_rows *csv_rows
      yield_chain = receive(:each_import_row)
      csv_rows.each do |cr|
        yield_chain = yield_chain.and_yield(cr)
      end
      allow(card).to yield_chain
      card.update_attributes! content: "import!"
    end

    describe "company mapping" do
      context "partial match" do
        it "uses suggestion if no correction" do
          import [answer_data(company: "Gooogle"), {}, match_type: :partial, suggestion: "Google Inc."]
          expect(answer_card).to be_a Card
          expect(Card["Google Inc", :aliases].item_names).to include "Gooogle"
        end

        it "uses correction when given" do
          import [answer_data(company: "Gooogle"), { company: "Google Inc." }, match_type: :partial, suggestion: "Amazon"]
          expect(answer_card).to be_a Card
          expect(Card["Google Inc", :aliases].item_names).to include "Gooogle"
        end

        it "creates new alias card" do
          expect(Card["Death Star", :aliases]).not_to be_a Card
          import [answer_data(company: "Gooogle"), { company: "Death Star" }, match_type: :partial, suggestion: "Amazon"]
          expect(answer_card(company: "Death Star")).to be_a Card
          expect(["Death Star", :aliases]).to denote_a_card
          expect(Card["Death Star", :aliases].item_names).to contain_exactly "Gooogle"
        end
      end

      context "no match" do
        it "creates company" do
          import [answer_data(company: "Gooogle"), {}, match_type: :none]
          expect(answer_card(company: "Gooogle")).to be_a Card
          expect(Card["Gooogle"]).to have_type :wikirate_company
        end

        it "uses correction when given" do
          import [answer_data(company: "Gooogle"), { company: "Google Inc." }, match_type: :none]
          expect(answer_card).to be_a Card
          expect(Card["Google Inc", :aliases].item_names).to include "Gooogle"
        end

        it "creates new alias card" do
          expect(Card["Death Star", :aliases]).not_to be_a Card
          import [answer_data(company: "Gooogle"), { company: "Death Star" }, match_type: :none]
          expect(answer_name(company: "Death Star")).to be_real
          expect(["Death Star", :aliases]).to be_real
          expect(Card["Death Star", :aliases].item_names).to contain_exactly "Gooogle"
        end
      end
    end
  end
end
