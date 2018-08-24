# -*- encoding : utf-8 -*-

class ImportMenuCards < Card::Migration
  def up
    import_cards 'menu_cards.json'
  end
end
