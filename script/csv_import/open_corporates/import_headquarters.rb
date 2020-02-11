require_relative "../../../config/environment"
require_relative "headquarters_csv_row"
require_relative "../../../mod/csv_import/lib/import_manager/script_import_manager.rb"

csv_path = File.expand_path "../data/additional_headquarter_codes.csv", __FILE__

file = CsvFile.new(csv_path, HeadquartersCsvRow, col_sep: ",", headers: true)

ScriptImportManager.new(file, user: "Philipp Kuehl", error_policy: :report).import
