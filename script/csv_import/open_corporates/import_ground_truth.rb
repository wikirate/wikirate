require_relative "../../../config/environment"
require_relative "open_corporates_csv_row"
require_relative "../csv_file"

csv_path = File.expand_path "../data/ground_truth_full_dataset.csv", __FILE__

CsvFile.new(csv_path, OpenCorporatesImportItem, col_sep: ";")
       .import user: "Philipp Kuehl", error_policy: :report
