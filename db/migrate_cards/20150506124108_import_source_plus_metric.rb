# -*- encoding : utf-8 -*-

class ImportSourcePlusMetric < Card::Migration
  def up
    import_json "source_plus_metric.json"
    
  end
end
