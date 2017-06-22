require_relative "../../../config/environment"
require_relative "open_corporates_csv_row"
require_relative "../csv_file"

csv_path = File.expand_path "../data/hesa_import.csv", __FILE__

Card::Auth.current_id = Card.fetch_id "Philipp Kuehl"

CSVFile.new(csv_path, OpenCorporatesCSVRow).import
