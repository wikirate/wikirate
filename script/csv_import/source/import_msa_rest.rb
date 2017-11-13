require_relative "../../../config/environment"
require_relative "source_csv_row"
require_relative "../csv_file"

csv_path = File.expand_path "../data/msa_rest.csv", __FILE__

CSVFile.new(csv_path, SourceCSVRow).import user: "Philipp Kuehl"
