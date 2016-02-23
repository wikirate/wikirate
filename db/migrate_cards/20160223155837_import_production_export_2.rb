# -*- encoding : utf-8 -*-

class ImportProductionExport2 < Card::Migration
  def up
    import_json 'production_export_2.json'
  end
end
