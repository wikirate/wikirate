# -*- encoding : utf-8 -*-

class ImportMetricStuff < Wagn::Migration
  def up
    import_json "metric_stuff.json"
    
  end
end
