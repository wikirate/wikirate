# -*- encoding : utf-8 -*-

class ImportHomepageDesign < Card::Migration
  def up
    import_cards 'homepage_design.json'
  end
end
