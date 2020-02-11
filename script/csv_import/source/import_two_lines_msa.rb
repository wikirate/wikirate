require_relative "../../../config/environment"
require_relative "source_csv_row"
require_relative "../csv_file"

csv_path = File.expand_path "../data/msa.csv", __FILE__

CsvFile.new(csv_path, SourceCsvRow).import user: "Philipp Kuehl"
