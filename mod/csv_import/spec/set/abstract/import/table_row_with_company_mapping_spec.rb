require_relative "../../../support/shared_table_row_examples"
require_relative "../../../support/shared_csv_data"

RSpec.describe Card::Set::Abstract::Import::TableRowWithCompanyMapping do
  include_context "csv data"

  include_context "table_row", Card::AnswerImportFileID do
    let(:csv_data) do
      answer_data
    end
  end

  def have_match_type type
    have_tag :input, with: { type: :hidden, name: "extra_data[0][match_type]",
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
    let(:row_data) do
      csv_row company: "Google Inc."
    end

    it "has class 'table-success'" do
      expect(row[:class]).to eq "table-success"
    end

    it "has csv row index as data attribute" do
      expect(row[:data][:csv_row_index]).to eq 0
    end

    specify "content" do
      expect(field(:checkbox))
        .to have_tag :input, with: { type: "checkbox", name: "import_rows[0]",
                                     value: "true" }
    end

    it "has no correction field" do
      expect(field(:checkbox))
        .not_to have_tag :input, with: { name: "extra_data[0][corrections]" }
    end
  end

  context "alias match" do
    let(:row_data) { csv_row company: "Alphabet" }

    it "has no correction field" do
      expect(field(:checkbox))
        .not_to have_tag :input, with: { name: "extra_data[0][corrections]" }
    end

    it "has hidden match type field" do
      expect(field(:checkbox)).to have_match_type :alias
    end
  end


  context "partial match" do
    let(:row_data) do
      csv_row company: "Sony"
    end
    it "has correction field" do
      expect(field(:company_correction))
        .to have_tag :input, with: { name: "extra_data[0][corrections][company]",
                                     value: "Sony Corporation" }
    end

    it "has hidden match type field" do
      expect(field(:checkbox)).to have_match_type :partial
    end
  end

  context "no match" do
    let(:row_data) do
      csv_row company: "Unknown Company"
    end

    it "has no correction field" do
      expect(field(:company_correction))
        .not_to have_tag :input, with: { name: "extra_data[0][corrections]" }
    end
  end
end
