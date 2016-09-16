# -*- encoding : utf-8 -*-

class ImportSourceImport < Card::Migration
  def up
    import_cards 'source_import.json'
  end
end
