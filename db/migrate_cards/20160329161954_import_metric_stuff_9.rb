# -*- encoding : utf-8 -*-

class ImportMetricStuff9 < Card::Migration
  def up
    import_json 'metric_stuff_9.json'
  end
end
