# -*- encoding : utf-8 -*-

class ImportMetricStuff2 < Card::Migration
  def up
    import_json 'metric_stuff_2.json'
  end
end
