# -*- encoding : utf-8 -*-

class ImportMetricStuff7 < Card::Migration
  def up
    import_json 'metric_stuff_7.json'
  end
end
