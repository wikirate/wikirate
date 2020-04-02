require_relative "../../../config/environment"
require_relative "metric_csv_row"
import_manager_dir = "../../../vendor/card-mods/csv_import/lib"
require_relative "#{import_manager_dir}/script_import_manager.rb"

csv_path = File.expand_path "../data/fti_2020_import.csv", __FILE__

file = CsvFile.new(csv_path, MetricCsvRow, col_sep: ",", headers: true)

ScriptImportManager.new(file, user: "Fashion Revolution", error_policy: :report).import
