# -*- encoding : utf-8 -*-

class UpdateAnalysesWithArticlesCount < Card::Migration
  def up
    import_json "company_contribution_details.json"
    # Card.search(:type=>'company').each do |company|
    #   company.fetch(:trait=>:analyses_with_articles).update_contribution_count
    # end
  end
end
