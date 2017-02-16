# -*- encoding : utf-8 -*-

class ImportHomepageDesign3 < Card::Migration
  def up
    import_cards 'homepage_design_3.json'
  end
end
