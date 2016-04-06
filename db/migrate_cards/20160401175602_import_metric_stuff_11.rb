# -*- encoding : utf-8 -*-

class ImportMetricStuff11 < Card::Migration
  def up
    import_json 'metric_stuff_11.json'
  end
end
