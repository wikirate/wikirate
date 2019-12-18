# -*- encoding : utf-8 -*-

class ImportHomepageFixes < Card::Migration
  def up
    import_cards 'homepage_fixes.json'
  end
end
