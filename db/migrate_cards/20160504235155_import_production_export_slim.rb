# -*- encoding : utf-8 -*-

class ImportProductionExportSlim < Card::Migration
  def up
    import_cards 'production_export_slim.json'
  end
end
