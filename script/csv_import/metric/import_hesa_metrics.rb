require_relative "../../../config/environment"
require_relative "metric_import_item"
require_relative "../csv_file"

csv_path = File.expand_path "../data/hesa_import.csv", __FILE__

CsvFile.new(csv_path, MetricImportItem).import user: "Philipp Kuehl"
