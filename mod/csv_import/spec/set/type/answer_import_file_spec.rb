require_relative "../../support/shared_csv_data"

module CSVData
  DATA = [
    ["Jedi+disturbances in the Force", "Death Star", "2017", "yes", "http://google.com", ""],
    ["Jedi+disturbances in the Force", "Google", "2017", "yes", "http://google.com", ""],
    ["Jedi+disturbances in the Force", "Sony", "2017", "yes", "http://google.com", ""],
    ["Jedi+disturbances in the Force", "New Company", "2017", "yes", "http://google.com", ""],
    ["Not a metric", "Monster Inc", "2017", "yes", "http://google.com", ""]
  ]

  def csv_file
    io = StringIO.new DATA.map { |rows| rows.join "," }.join "\n"
    CSVFile.new io, AnswerCSVRow
  end
end


describe Card::Set::Type::AnswerImportFile do
  include CSVData
  include_context "csv data"
  let(:card) { Card["A"].with_set(described_class) }
  let(:format) { card.format_with_set(described_class, :html) }
  specify do
    allow(card).to receive(:file).and_return true
    allow(card).to receive(:csv_file).and_return answer_csv_file
    expect(format.render_import_table).to have_tag "table"
  end

  describe "import table" do
    it "sorts by match type" do
      allow(card).to receive(:file).and_return true
      allow(card).to receive(:csv_file).and_return csv_file
      expect(format.render_import_table).to have_tag :table do
        with_tag :tbody do
          with_text /Not a metric.+New Company.+Sony.+Google.+Death Star/m
        end
      end
    end
  end

end
