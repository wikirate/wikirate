# -*- encoding : utf-8 -*-

class ImportMetricValueStructure < Card::Migration
  def up
    import_json "metric_value_structure.json"
    
  end
end
