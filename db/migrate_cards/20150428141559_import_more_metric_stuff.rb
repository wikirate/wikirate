# -*- encoding : utf-8 -*-

class ImportMoreMetricStuff < Card::Migration
  def up
    import_json "more_metric_stuff.json"
    
  end
end
