# -*- encoding : utf-8 -*-

class ImportMetricStuff10 < Card::Migration
  def up
    import_json 'metric_stuff_10.json'
  end
end
