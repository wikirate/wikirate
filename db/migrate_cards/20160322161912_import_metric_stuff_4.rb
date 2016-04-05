# -*- encoding : utf-8 -*-

class ImportMetricStuff4 < Card::Migration
  def up
    import_json 'metric_stuff_4.json'
  end
end
