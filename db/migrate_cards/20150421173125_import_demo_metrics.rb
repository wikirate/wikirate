# -*- encoding : utf-8 -*-

class ImportDemoMetrics < Card::Migration
  def up
    Card::Auth.current_id = Card.fetch_id "Maxi"
    Card::Auth.as_bot { import_json "maxis_metrics.json" }
    Card::Auth.current_id = Card.fetch_id "Lucia Lu"
    Card::Auth.as_bot { import_json "lucys_metrics.json" }
  end
end
