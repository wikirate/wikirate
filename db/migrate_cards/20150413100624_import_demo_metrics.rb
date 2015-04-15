# -*- encoding : utf-8 -*-

class ImportDemoMetrics < Card::Migration
  def up
    import_json "demo_metrics.json"
    
  end
end
