# -*- encoding : utf-8 -*-

class ImportMetricValueTypes < Card::Migration
  def up
    import_json "metric_value_types.json"
    
  end
end
