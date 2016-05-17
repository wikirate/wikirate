# -*- encoding : utf-8 -*-

class ImportUpdateMetricStuff < Card::Migration
  def up
    import_json "update_metric_stuff.json"
  end
end
