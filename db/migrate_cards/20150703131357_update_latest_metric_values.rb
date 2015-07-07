# -*- encoding : utf-8 -*-

class UpdateLatestMetricValues < Card::Migration
  def up
    Card.create! :name=>'latest value year', :codename=>'latest_value_year',
      :subcards=>{'+*right+*update'=>'[[Administrator]]', '+*right+*delete'=>'[[Administrator]]'}
    Card::Cache.reset_global
    # Card.search(:left=>{:type=>'metric'}, :right=>{:type=>'company'}).each do |metric_value_set_card|
    #   if metric_value_set_card.respond_to? :update_latest_value_year
    #     metric_value_set_card.update_latest_value_year
    #   else
    #     puts "Problems with #{metric_value_set_card.name}"
    #   end
    # end
  end
end
