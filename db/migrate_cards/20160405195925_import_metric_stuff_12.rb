# -*- encoding : utf-8 -*-

class ImportMetricStuff12 < Card::Migration
  def up
    import_json 'metric_stuff_12.json'
  end
end
