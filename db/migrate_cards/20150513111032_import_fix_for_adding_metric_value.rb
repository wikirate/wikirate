# -*- encoding : utf-8 -*-

class ImportFixForAddingMetricValue < Card::Migration
  def up
    import_json "fix_for_adding_metric_value.json"
    
  end
end
