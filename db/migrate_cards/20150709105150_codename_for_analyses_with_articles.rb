# -*- encoding : utf-8 -*-

class CodenameForAnalysesWithArticles < Card::Migration
  def up
    Card.fetch("Analyses with articles").update_attributes! :codename=>'analyses_with_articles'
  end
end
