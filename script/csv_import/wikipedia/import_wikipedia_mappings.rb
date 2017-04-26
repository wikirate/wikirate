require_relative "../../../config/environment"
require_relative "wikipedia_csv_row"
require_relative "../csv_file"

csv_path = File.expand_path "../data/error.csv", __FILE__
Card::Auth.current_id = Card.fetch_id "Vasiliki Gkatziaki"
CSVFile.new(csv_path, WikipediaCSVRow).import error_policy: :report
