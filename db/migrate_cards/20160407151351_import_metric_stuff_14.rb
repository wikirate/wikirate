# -*- encoding : utf-8 -*-

class ImportMetricStuff14 < Card::Migration
  def up
    import_json 'metric_stuff_14.json'
  end
end
