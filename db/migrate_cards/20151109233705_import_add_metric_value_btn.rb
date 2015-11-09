# -*- encoding : utf-8 -*-

class ImportAddMetricValueBtn < Card::Migration
  def up
    import_json "add_metric_value_btn.json"
    
  end
end
