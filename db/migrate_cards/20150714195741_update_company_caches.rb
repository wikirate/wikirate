# -*- encoding : utf-8 -*-

class UpdateCompanyCaches < Card::Migration
  def up
    Card::Cache.reset_global
    Card.search(:type=>'company').each do |company|
      unless company.key == 'ikea' # ikea is causing trouble
        company.fetch(:trait=>:analyses_with_articles).update_cached_count
        company.fetch(:trait=>:source).update_cached_count
        company.fetch(:trait=>:metric).update_cached_count
        company.update_contribution_count
      end
    end
  end
end
