require_relative "../../../config/environment"
require_relative "wikipedia_csv_file"

csv_path = File.expand_path "../data/WikiRate2Wikipedia.csv", __FILE__
Card::Auth.current_id = Card.fetch_id "Vasiliki Gkatziaki"
WikipediaCSVFile.new(csv_path).import!
