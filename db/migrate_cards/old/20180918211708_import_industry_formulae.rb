# -*- encoding : utf-8 -*-

class ImportIndustryFormulae < Card::Migration
  def up
    import_cards 'industry_formulae.json'
  end
end
