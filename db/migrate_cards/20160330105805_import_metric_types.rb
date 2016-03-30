# -*- encoding : utf-8 -*-

class ImportMetricTypes < Card::Migration
  def up
    import_json 'metric_types.json'
  end
end
