# -*- encoding : utf-8 -*-

class ImportMenuCards < Cardio::Migration
  def up
    import_cards 'menu_cards.json'
  end
end
