# -*- encoding : utf-8 -*-

class ImportHomepageDesign2 < Card::Migration
  def up
    import_cards 'homepage_design_2.json'
  end
end
