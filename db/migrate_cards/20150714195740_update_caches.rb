# -*- encoding : utf-8 -*-

class UpdateCaches < Card::Migration
  def up
    Card::Cache.reset_global
    Card.search(:type=>'company').each do |company|
      company.fetch(:trait=>:analyses_with_articles).update_cached_count
      company.fetch(:trait=>:source).update_cached_count
      company.fetch(:trait=>:metric).update_cached_count
      company.update_contribution_count
    end
    Card::Cache.reset_global
    Card.search(:type=>'analysis').each do |analysis|
      company.fetch(:trait=>:claim).update_cached_count
      company.fetch(:trait=>:source).update_cached_count
    end
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
