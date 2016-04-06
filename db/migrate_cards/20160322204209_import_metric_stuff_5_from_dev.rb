# -*- encoding : utf-8 -*-

class ImportMetricStuff5FromDev < Card::Migration
  def up
    import_json 'metric_stuff_5_from_dev.json'
  end
end
