require_relative "../../../../support/shared_csv_import"

RSpec.describe Card::Set::TypePlusRight::Source::File::ImportAnswersFromSource do
  include_context "csv import" do
    let(:csv_row_class) { CSVRow::Structure::AnswerFromSourceCSV }
    let(:import_card) { Card["answer from source import test+file"] }
    let(:data) do
      {
        wrong_value:       ["Monster Inc", "5"],
        no_match:          ["Not a company", "yes"],
        alias_match:       ["amazon.com", "yes"],
        exact_match:       ["Apple Inc.", "yes"],
        partial_match:     ["Sony", "no"],
        duplicate_in_file: ["Apple Inc.", "no"],
        existing_value:    ["Death Star", "no"]
      }
    end
  end

  let(:metric) { "Jedi+disturbances in the Force" }
  let(:year) { "2001" }

  include_context "answer import" do
    let(:company_row) { 0 }
    let(:value_row) { 1 }
  end


  def trigger_import_with_metric_and_year *args
    args << { all: { corrections: {
      metric: { content: metric },
      year: { content: year }
    } } }
    trigger_import(*args)
  end

  describe "import action" do
    before do
      login_as "joe_user"
    end

    it "creates answer" do
      trigger_import_with_metric_and_year(:exact_match)
      expect_answer_created :exact_match
    end

    it "fails if no metric is given" do
      expect { trigger_import(:exact_match) }
        .to raise_error /Please give a Metric./
    end

    it "fails if no year is given" do
      expect { trigger_import(:exact_match) }
        .to raise_error /Please give a Year./
    end

    it "reports error if value type doesn't fit" do
      trigger_import_with_metric_and_year(:wrong_value)
      expect(errors).to contain_exactly(/5 is not a valid option/)
    end

    it "reports duplicated value in file" do
      trigger_import_with_metric_and_year(:exact_match, :duplicate_in_file)
      # binding.pry
      expect(status[:reports][5])
        .to contain_exactly "Jedi+disturbances in the Force+Apple Inc.+2001 duplicate in this file"
    end

    it "doesn't update existing value" do
      trigger_import_with_metric_and_year(:existing_value)
      expect_answer_created(:existing_value, with_value: "yes")
    end

    context "with conflict strategy :override" do
      it "updates existing value with different value" do
        Card::Env.params[:conflict_strategy] = :override
        trigger_import_with_metric_and_year(:existing_value)
        expect_answer_created(:existing_value)
      end
    end

    context "company correction name is filled" do
      it "uses the corrected name as company name" do
        trigger_import_with_metric_and_year(
          partial_match: { company_match_type: :partial,
                           corrections: { company: "Sony Corporation" } },
        )
        expect_card(answer_name(company: "Sony Corporation")).to exist
          .and have_a_field(:value).with_content "no"
      end

      it "adds corrected name to company's aliases" do
        trigger_import_with_metric_and_year(
          partial_match: { company_match_type: :partial,
                           corrections: { company: "Sony Corporation" } },
        )

        expect_card("Sony Corporation")
          .to have_a_field(:aliases).pointing_to "Sony"
      end

      it "creates non-existent company and the value" do
        trigger_import_with_metric_and_year :no_match
        expect(Card["not a company"]).to have_type :wikirate_company
        expect_answer_created :no_match
      end
    end
  end

  describe "view: import_table" do
    include_context "table row matcher"

    let(:additional_fields) do
      import_card_with_rows(:exact_match).format._render_additional_form_fields
    end

    it "has metric field" do
      expect(additional_fields)
        .to have_tag "input.d0-card-content.form-control",
                     with: { name: "extra_data[all][corrections][metric][content]" }
    end

    it "has year field" do
      expect(additional_fields)
        .to have_tag "input.d0-card-content.form-control",
                     with: { name: "extra_data[all][corrections][year][content]" }
    end

    it "renders table correctly" do
      table = import_card_with_rows(:no_match, :partial_match, :alias_match, :exact_match)
                .format._render_import_table
      expect(table).to have_tag("table", with: { class: "import_table" }) do
        with_row index: 0,
                 context: :danger,
                 checked: false,
                 match: :none,
                 suggestion: "Not a company",
                 fields: ["1", "Not a company", "yes"]
        with_row index: 1,
                 context: :info,
                 checked: true,
                 match: :partial,
                 suggestion: "Sony Corporation",
                 fields: ["2", "Sony", "Sony Corporation", "no"]
        with_row index: 2,
                 context: :info,
                 checked: true,
                 match: :alias,
                 suggestion: "Amazon.com, Inc.",
                 fields: ["3", "Amazon.com, Inc.", "amazon.com", "yes"]
        with_row index: 3,
                 context: :success,
                 checked: true,
                 match: :exact,
                 suggestion: "Apple Inc.",
                 fields: ["4", "Apple Inc.", "yes"]
      end
    end
  end
end
