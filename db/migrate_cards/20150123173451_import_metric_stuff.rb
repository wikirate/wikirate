# -*- encoding : utf-8 -*-

class ImportMetricStuff < Card::Migration
  def up
    import_json "metric_stuff.json"
  end
end
