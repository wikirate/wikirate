require_relative "../../../config/environment"
require_relative "logo_csv_row"
require_relative "../csv_file"

csv_path = File.expand_path "../data/company_logos.csv", __FILE__
CSVFile.new(csv_path, LogoCSVRow)
       .import user: "Vasiliki Gkatziaki", error_policy: :report
