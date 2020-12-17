# -*- encoding : utf-8 -*-

class ImportIndustryValueOptions < Cardio::Migration
  def up
    import_cards 'industry_value_options.json'
  end
end
