# -*- encoding : utf-8 -*-

class ImportHomepageDesign4 < Card::Migration
  def up
    import_cards 'homepage_design_4.json'
  end
end
