require_relative "../../../support/shared_table_row_examples"
require_relative "../../../support/shared_csv_data"

RSpec.describe Card::Set::Abstract::Import::TableRowWithCompanyMapping do
  include_context "csv data"
  include_context "table_row",  Card::MetricValueImportFileID do
    let(:csv_data) do
      answer_csv_row
    end
  end

  def have_match_type type
    have_tag :input, with: { name: "import_data[1][extra_data][match_type]",
                             value: type }
  end

  context "invalid data" do
    context "no company" do
      let(:row_data) { csv_row company: nil }
      specify do
        expect(field(:checkbox)).to be_disabled
      end
    end

    context "no metric" do
      let(:row_data) { csv_row metric: nil }
      specify do
        expect(field(:checkbox)).to be_disabled
      end
    end

    context "invalid metric" do
      let(:row_data) { csv_row metric: "this is not a metric" }
      specify do
        expect(field(:checkbox)).to be_disabled
      end
    end

    context "no year" do
      let(:row_data) { csv_row year: nil }
      specify do
        expect(field(:checkbox)).to be_disabled
      end
    end

    context "invalid year" do
      let(:row_data) { csv_row year: "Google Inc" }
      specify do
        expect(field(:checkbox)).to be_disabled
      end
    end

    context "no value" do
      let(:row_data) { csv_row value: nil }
      specify do
        expect(field(:checkbox)).to be_disabled
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
      expect(row[:data][:csv_row_index]).to eq 1
    end

    specify "content" do
      expect(field(:checkbox))
        .to have_tag :input, with: { type: "checkbox",
                                     name: "import_data[1][import]",
                                     value: "true" }
    end

    it "has no correction field" do
      expect(field(:checkbox))
        .not_to have_tag :input, with: { name: "import_data[1][corrections]" }
    end
  end

  context "alias match" do
    let(:row_data) { csv_row company: "Alphabet" }

    it "has no correction field" do
      expect(field(:checkbox))
        .not_to have_tag :input, with: { name: "import_data[1][corrections]" }
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
        .to have_tag :input, with: { name: "import_data[1][corrections][company]",
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
        .not_to have_tag :input, with: { name: "import_data[1][corrections]" }
    end
  end
end
