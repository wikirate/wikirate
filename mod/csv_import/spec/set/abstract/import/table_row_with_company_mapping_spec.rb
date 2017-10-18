require_relative "../../../support/shared_table_row_examples"
require_relative "../../../support/shared_answer_csv_row"

RSpec.describe Card::Set::Abstract::Import::TableRowWithCompanyMapping do
  include_context "answer csv row"

  include_context "table_row", Card::AnswerImportFileID do
    let(:csv_data) {answer_row}
  end

  def have_match_type type
    have_tag :input, with: { type: :hidden, name: "extra_data[0][company_match_type]",
                             value: type }
  end

  context "invalid data" do
    def expect_disabled_checkbox row
      index = Card::Set::Type::AnswerImportFile::COLUMNS.keys.index(:checkbox)
      expect(row[:content][index]).to be_disabled
    end

    def be_disabled
      have_tag :input, with: { name: "import_rows[0]", value: true, disabled: "disabled" }
    end

    example "no company" do
      validated_table_row company: nil do |row|
        expect_disabled_checkbox(row)
      end
    end

    example "no metric" do
      validated_table_row metric: nil do |row|
        expect_disabled_checkbox row
      end
    end

    example "invalid metric" do
      validated_table_row metric: "this is not a metric" do |row|
        expect_disabled_checkbox row
      end
    end

    example "no year" do
      validated_table_row year: nil do |row|
        expect_disabled_checkbox row
      end
    end

    example "invalid year" do
      validated_table_row year: "Google Inc" do |row|
        expect_disabled_checkbox row
      end
    end

    example "no value" do
      validated_table_row value: nil do |row|
        expect_disabled_checkbox row
      end
    end
  end

  context "exact match" do
    let(:row_data) {csv_row company: "Google Inc."}

    around do |example|
      with_row row_data do
        example.run
      end
    end

    it "has class 'table-success'" do
      expect(field(:company)[:class]).to eq "table-success"
    end

    it "has csv row index as data attribute" do
      expect(row[:data][:csv_row_index]).to eq 0
    end

    specify "content" do
      expect(field(:checkbox))
        .to have_tag :input, with: { type: "checkbox", name: "import_rows[0]" }
    end

    it "has no correction field" do
      expect(field(:checkbox))
        .not_to have_tag :input, with: { name: "extra_data[0][corrections]" }
    end
  end

  context "alias match" do
    let(:row_data) {csv_row company: "Alphabet"}

    around do |example|
      with_row row_data do
        example.run
      end
    end

    it "has class 'table-warning'" do
      expect(field(:company)[:class]).to eq "table-alias"
    end

    it "has no correction field" do
      expect(field(:checkbox))
        .not_to have_tag :input, with: { name: "extra_data[0][corrections]" }
    end

    it "has hidden match type field" do
      expect(field(:checkbox)).to have_match_type :alias
    end
  end


  context "partial match" do
    let(:row_data) { csv_row company: "Sony" }

    around do |example|
      with_row row_data do
        example.run
      end
    end

    it "has correction field" do
      expect(field(:company_correction)[:content])
        .to have_tag :input, with: { name: "extra_data[0][corrections][company]",
                                     value: "Sony Corporation" }
    end

    it "has hidden match type field" do
      expect(field(:checkbox)).to have_match_type :partial
    end

    context "invalid data" do
      let(:row_data) {csv_row company: "Sony", metric: nil}
      it "has no correction field" do
        expect(field(:company_correction)[:content])
          .not_to have_tag :input,
                           with: { name: "extra_data[0][corrections][company]" }
      end
    end
  end

  context "no match" do
    let(:row_data) { csv_row company: "Unknown Company" }

    it "has no correction field" do
      with_row row_data do
        expect(field(:company_correction)[:content])
          .not_to have_tag :input, with: { name: "extra_data[0][corrections]" }
      end
    end
  end
end
