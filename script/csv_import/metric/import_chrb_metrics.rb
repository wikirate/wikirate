require_relative "../../../config/environment"
require_relative "metric_csv_row"
require_relative "../../../mod/wikirate_csv_import/lib/import_manager/script_import_manager.rb"

csv_path = File.expand_path "../data/CHRB_import.csv", __FILE__

file = CSVFile.new(csv_path, MetricCSVRow, col_sep: ";", headers: true)

ScriptImportManager.new(file, user: "Philipp Kuehl", error_policy: :report).import
