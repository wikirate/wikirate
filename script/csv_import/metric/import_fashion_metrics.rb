require_relative "../../../config/environment"
require_relative "metric_csv_row"
require_relative "../../../vendor/card-mods/csv_import/lib/import_manager/script_import_manager.rb"

csv_path = File.expand_path "../data/fashion_import.csv", __FILE__

file = CSVFile.new(csv_path, MetricCSVRow, col_sep: ",", headers: true)

ScriptImportManager.new(file, user: "Aileen Robinson", error_policy: :report).import
