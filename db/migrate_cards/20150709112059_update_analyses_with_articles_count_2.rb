# -*- encoding : utf-8 -*-

class UpdateAnalysesWithArticlesCount2 < Card::Migration
  def up
    Card.search(:type=>'company').each do |company|
      company.fetch(:trait=>:analyses_with_articles).update_contribution_count
    end
  end
end
