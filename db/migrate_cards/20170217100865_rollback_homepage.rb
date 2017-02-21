# -*- encoding : utf-8 -*-

class RollbackHomepage < Card::Migration
  def up
    merge_cards ["home", "homepage_company_item", "homepage_metric_item",
                 "homepage_topic_item", "nav_bar_menu",
                 "homepage_wikirate_get_it_right", "homepage_top_banner"]
  end
end
