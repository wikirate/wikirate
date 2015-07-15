# -*- encoding : utf-8 -*-

class UpdateCaches < Card::Migration
  def up
    Card::Cache.reset_global
    Card.search(:left=>{:type=>'metric'}, :right=>{:type=>'company'}).each do |metric_value_set_card|
      if metric_value_set_card.respond_to? :update_cached_count
        metric_value_set_card.update_cached_count
      else
        puts "Problems with #{metric_value_set_card.name}"
      end
    end
  end
end
