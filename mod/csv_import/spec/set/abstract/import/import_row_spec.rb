RSpec.describe Card::Set::Abstract::Import::ImportRow do
  def csv_row company
    MetricAnswerCSVRow.new(
                  { metric: "Jedi+disturbances in the Force",
                        file_company: company,
                        year: "2017",
                        value: "5",
                        source: "http://google.com",
                        comment: "" },1)
  end

  let(:format) do
        Card.new(name: "I", type_id: Card::MetricValueImportFileID)
            .format(:html)
  end
  let(:row_content) do
    row[:content].first
  end
  let(:row) do
    Card::Set::Abstract::Import::ImportRowWithCompanyMapping.new(row_data, format).render
  end

  context "exact match" do
    let(:row_data) do
      csv_row "Google Inc."
    end


    it "has class 'table-success'" do
      expect(row[:class]).to eq "table-success"
    end

    it "has csv row index as data attribute" do
      expect(row[:data][:csv_row_index]).to eq 1
    end

    specify "content" do
      expect(row_content)
        .to have_tag :input, with: { type: "checkbox",
                                             name: "import_data[1][import]",
                                             value: "true" }
    end

    it "has no correction field" do
      expect(row_content)
        .not_to have_tag :input, with: { name: "import_data[1][corrections]"}
    end
  end

  context "partial match" do
    let(:row_data) do
      csv_row "Google"
    end
  end

end
