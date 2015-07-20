# -*- encoding : utf-8 -*-

class Caching < Card::Migration
  def up
    Card.fetch("Analyses with articles").update_attributes! :codename=>'analyses_with_articles'
    Card['yinyang drag item'].update_attributes! :codename=>'yinyang_drag_item'
    import_json "caching.json"
    Card.create! :name=>'*cached count', :codename=>'cached_count',
      :subcards=>{'+*right+*update'=>'[[Administrator]]', '+*right+*delete'=>'[[Administrator]]'}
  end
end
