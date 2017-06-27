require_relative "../../../config/environment"
require_relative "open_corporates_csv_row"
require_relative "../csv_file"

csv_path = File.expand_path "../data/ground_truth.csv", __FILE__

CSVFile.new(csv_path, OpenCorporatesCSVRow)
       .import user: "Philipp Kuehl", error_policy: :report
