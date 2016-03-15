# -*- encoding : utf-8 -*-

class ImportMetricStuff1 < Card::Migration
  def up
    import_json 'metric_stuff_1.json'
  end
end
