# -*- encoding : utf-8 -*-

class ImportBrowseSourceStyle < Card::Migration
  def up
    import_cards 'browse_source_style.json'
  end
end
