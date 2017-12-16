require_relative "../../support/shared_csv_import"
require_relative "../../support/shared_answer_import_examples"

RSpec.describe Card::Set::Type::RelationshipAnswerImportFile, type: :controller do
  routes { Decko::Engine.routes }
  before { @controller = CardController.new }

  include_context "with company matches"
  let(:default_data) do
    {
      designer: "Jedi",
      title: "more evil",
      company: "Death Star",
      related_company: "Google Inc.",
      year: "2017",
      value: "yes",
      source: "http://google.com",
      comment: ""
    }
  end

  describe "view: import_table" do
    include_context "csv import" do
      let(:csv_row_class) { CSVRow::Structure::RelationshipAnswerCSV }
      let(:import_card) { Card["relationship answer import test"] }

      let(:data) do
        [:exact, :alias, :partial, :no].repeated_permutation(2)
                                       .each_with_object({}) do  |(match1, match2), h|
          h["#{match1}_#{match2}_match".to_sym] = {
            company: send("#{match1}_match"),
            related_company: send("#{match2}_match")
          }
        end.merge(
          not_a_metric: { title: "Not a metric", company: "Monster Inc" }
        )
      end
    end

    it "sorts by match type" do
      import_card = import_card_with_data
      allow(import_card).to receive(:file).and_return true
      table = import_card.format(:html)._render_import_table
      expect(table).to have_tag :table do
        with_tag :tbody do
          with_text /Not a metric.+New Company.+Sony.+Google.+Death Star/m
        end
      end
    end

    def table *rows
      import_card_with_rows(*rows).format(:html)._render_import_table
    end

    it "has no invalid alert if all data is valid" do
      expect(table(:exact_exact_match, :alias_alias_match))
        .not_to have_tag "div.alert"
    end

    it "has invalid alert if data is invalid" do
      expect(table(:not_a_metric))
        .to have_tag "div.alert.alert-danger" do
        with_tag :h4, text: "Invalid data"
        with_tag :ul, text: /Not a metric/
      end
    end
  end

  describe "import csv file" do
    include_context "csv import" do
      let(:csv_row_class) { CSVRow::Structure::RelationshipAnswerCSV }
      let(:import_card) { Card["relationship answer import test"] }
      let(:data) do
        {
          exact_match:
            { source: "http://google.com/1", comment: "chch" },
          alias_match:
            { company: "Google", source: "http://google.com/2" },
          partial_match:
            { company: "Sony", source: "http://google.com/3" },
          no_match:
            { company: "New Company", source: "http://google.com/4" },
          not_a_metric:
            { metric: "Not a metric", company: "Monster Inc",
              source: "http://google.com/5" },
          not_a_company:
            { company: "A", source: "http://google.com/6" },
          company_missing:
            { company: "", source: "http://google.com/7" },
          missing_and_invalid:
            { metric: "Not a metric", company: "", source: "http://google.com/8" },
          conflict_same_value_same_source:
            { company: "Death Star", year: "2000",
              source: "http://www.wikiwand.com/en/Opera" },
          conflict_same_value_different_source:
            { company: "Death Star", year: "2000", source: "http://google.com/10" },
          conflict_different_value:
            [default_data[:metric], "Death Star", "2000", "no", "http://google.com/11",
             "overridden"],
          invalid_value:
            { company: "Death Star", value: "100", source: "http://google.com/12" },
          monster_badge_1:
            { company: "Monster Inc.", year: "2000", source: "http://google.com/13" },
          monster_badge_2:
            { company: "Monster Inc.", year: "2001", source: "http://google.com/14" },
          monster_badge_3:
            { company: "Monster Inc.", year: "2002", source: "http://google.com/15" },
          wikirate_source:
            { source: sample_source.name }
        }
      end
    end

    let(:metric) { "Jedi+more evil" }
    let(:year) { "2017" }

    include_context "answer import" do
      let(:company_row) { 2 }
      let(:value_row) { 5 }
    end

    include_examples "answer import examples" do
      let(:import_file_type_id) { Card::RelationshipAnswerImportFileID }
      let(:attachment_name) { :relationship_answer_import_file }
      let(:import_file_name) { "relationship_answer_test" }
      let(:unordered_import_file_name) { "relationship_wrong_order" }

      def related_company_name key, _override
        key.is_a?(Symbol) ? data_row(key)[company_row + 1] : key[:related_company]
      end

      def answer_name key, override={}
        [metric, company_name(key, override), year,
         related_company_name(key, override)].join "+"
      end
    end
  end
end
