require_relative "../../../config/environment"
require_relative "metrics_csv_file"

csv_path = File.expand_path "../data/hesa_import.csv", __FILE__

Card::Auth.current_id = Card.fetch_id "Philipp Kuehl"

MetricsCSVFile.new(csv_path).import!
