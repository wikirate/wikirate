# -*- encoding : utf-8 -*-

class Caching < Card::Migration
  def up
    Card.fetch("Analyses with articles").update_attributes! :codename=>'analyses_with_articles'
    import_json "company_contribution_details.json"
    Card.create! :name=>'*cached count', :codename=>'cached_count',
      :subcards=>{'+*right+*update'=>'[[Administrator]]', '+*right+*delete'=>'[[Administrator]]'}

    # update caches
    # Card::Cache.reset_global
    # Card.search(:type=>'company').each do |company|
    #   company.fetch(:trait=>:analyses_with_articles).update_cached_count
    # end
    # Card.search(:left=>{:type=>'metric'}, :right=>{:type=>'company'}).each do |metric_value_set_card|
    #   if metric_value_set_card.respond_to? :update_latest_value_year
    #     metric_value_set_card.update_latest_value_year
    #   else
    #     puts "Problems with #{metric_value_set_card.name}"
    #   end
    # end
  end
end
