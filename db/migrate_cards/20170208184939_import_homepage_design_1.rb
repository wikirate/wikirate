# -*- encoding : utf-8 -*-

class ImportHomepageDesign1 < Card::Migration
  def up
    import_cards 'homepage_design_1.json'
  end
end
