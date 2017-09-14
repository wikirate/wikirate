# -*- encoding : utf-8 -*-

class AddReportSearch < Card::Migration
  def up
    merge_cards ["report_search", "report_search+*right+*structure"]
    Card::Codename.reset_cache
  end
end
