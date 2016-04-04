# -*- encoding : utf-8 -*-

class ImportMetricStuff6FromDev < Card::Migration
  def up
    import_json 'metric_stuff_6_from_dev.json'
  end
end
