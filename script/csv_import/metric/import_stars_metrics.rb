require_relative "../../../config/environment"
require_relative "metrics_import_item"
require_relative "../../csv_file"

csv_path = File.expand_path "../data/stars_import.csv", __FILE__
CsvFile.new(csv_path, MetricImportItem).import user: "Laureen van Breen"
