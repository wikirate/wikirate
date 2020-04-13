require_relative "../../../config/environment"
require_relative "open_corporates_import_item_only_headquarters"
require_relative "../../../mod/csv_import/lib/import_manager/script_import_manager.rb"

csv_path = File.expand_path "../data/oc_mappings_vol2.csv", __FILE__

file = CsvFile.new(csv_path, OpenCorporatesImportItemOnlyHeadquarters,
                   col_sep: ";", headers: true)

ScriptImportManager.new(file, user: "Philipp Kuehl", error_policy: :report).import
