# -*- encoding : utf-8 -*-

class ImportMetricImportScript < Card::Migration
  def up
    import_json "metric_import_script.json"
    
  end
end
