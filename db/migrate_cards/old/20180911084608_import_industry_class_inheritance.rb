# -*- encoding : utf-8 -*-

class ImportIndustryClassInheritance < Cardio::Migration
  def up
    import_cards 'industry_class_inheritance.json'
  end
end
