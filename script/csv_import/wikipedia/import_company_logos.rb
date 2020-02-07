require_relative "../../../config/environment"
require_relative "logo_csv_row"
require_relative "../csv_file"

csv_path = File.expand_path "../data/company_logos.csv", __FILE__
CsvFile.new(csv_path, LogoCsvRow)
       .import user: "Vasiliki Gkatziaki", error_policy: :report
