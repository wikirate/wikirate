# -*- encoding : utf-8 -*-

class ImportSourcePreviewUpdates < Card::Migration
  def up
    import_cards 'source_preview_updates.json'
  end
end
