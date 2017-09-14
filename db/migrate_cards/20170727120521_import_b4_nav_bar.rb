# -*- encoding : utf-8 -*-

class ImportB4NavBar < Card::Migration
  def up
    import_cards 'b4_nav_bar.json'
  end
end
