# -*- encoding : utf-8 -*-

class ImportMetricStuff13 < Card::Migration
  def up
    import_json 'metric_stuff_13.json'
  end
end
