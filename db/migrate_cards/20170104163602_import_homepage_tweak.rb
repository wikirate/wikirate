# -*- encoding : utf-8 -*-

class ImportHomepageTweak < Card::Migration
  def up
    import_cards 'homepage_tweak.json'
  end
end
