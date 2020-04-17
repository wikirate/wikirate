require_relative "../../../config/environment"
require_relative "logo_import_item"
require_relative "../csv_file"

csv_path = File.expand_path "../data/company_logos.csv", __FILE__
CsvFile.new(csv_path, LogoImportItem)
       .import user: "Vasiliki Gkatziaki", error_policy: :report
