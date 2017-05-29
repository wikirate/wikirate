require_relative "../../../config/environment"
require_relative "logo_csv_row"
require_relative "../csv_file"

csv_path = File.expand_path "../data/company_logos.csv", __FILE__
Card::Auth.current_id = Card.fetch_id "Vasiliki Gkatziaki"
CSVFile.new(csv_path, LogoCSVRow, col_sep: ";").import error_policy: :report
