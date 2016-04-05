# -*- encoding : utf-8 -*-

class ImportMetricStuff3FromDev < Card::Migration
  def up
    import_json 'metric_stuff_3_from_dev.json'
  end
end
