# -*- encoding : utf-8 -*-
# ImportMetricValueImportFile
class ImportMetricValueImportFile < Card::Migration
  def up
    import_json "metric_value_import_file.json"
  end
end
