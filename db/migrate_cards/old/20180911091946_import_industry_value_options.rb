# -*- encoding : utf-8 -*-

class ImportIndustryValueOptions < Card::Migration
  def up
    import_cards 'industry_value_options.json'
  end
end
