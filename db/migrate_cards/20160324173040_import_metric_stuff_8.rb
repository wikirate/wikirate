# -*- encoding : utf-8 -*-

class ImportMetricStuff8 < Card::Migration
  def up
    import_json 'metric_stuff_8.json'
  end
end
