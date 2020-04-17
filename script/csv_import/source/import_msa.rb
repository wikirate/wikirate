require_relative "../../../config/environment"
require_relative "source_import_item"
require_relative "../csv_file"

csv_path = File.expand_path "../data/msa.csv", __FILE__

CsvFile.new(csv_path, SourceImportItem).import user: "Philipp Kuehl"
