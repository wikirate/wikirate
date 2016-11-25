# -*- encoding : utf-8 -*-

class ImportStyleProgress < Card::Migration
  def up
    import_cards 'style_progress.json'
  end
end
