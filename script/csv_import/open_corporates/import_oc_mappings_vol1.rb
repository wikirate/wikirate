require_relative "../../../config/environment"
require_relative "open_corporates_import_item_compact"

csv_path = File.expand_path "../data/oc_mappings_vol1.csv", __FILE__

CsvFile.new(csv_path, OpenCorporatesImportItemCompact, col_sep: ";")
       .import user: "Philipp Kuehl", error_policy: :report
