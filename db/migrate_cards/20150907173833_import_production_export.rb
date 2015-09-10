# -*- encoding : utf-8 -*-

class ImportProductionExport < Card::Migration
  def up
    import_json "production_export.json"
    
  end
end
