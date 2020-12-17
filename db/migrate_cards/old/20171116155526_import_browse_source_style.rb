# -*- encoding : utf-8 -*-

class ImportBrowseSourceStyle < Cardio::Migration
  def up
    import_cards 'browse_source_style.json'
  end
end
