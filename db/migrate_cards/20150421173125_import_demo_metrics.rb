# -*- encoding : utf-8 -*-

class ImportMaxisMetrics < Card::Migration
  def up
    Card::Auth.current = Card.fetch "Maxi"
    import_json "maxis_metrics.json"
    Card::Auth.current = Card.fetch "Lucia Lu"
    import_json "lucys_metrics.json"
  end
end
