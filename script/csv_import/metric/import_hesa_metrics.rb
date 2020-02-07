require_relative "../../../config/environment"
require_relative "metric_csv_row"
require_relative "../csv_file"

csv_path = File.expand_path "../data/hesa_import.csv", __FILE__

CsvFile.new(csv_path, MetricCsvRow).import user: "Philipp Kuehl"
