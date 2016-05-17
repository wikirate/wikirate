# -*- encoding : utf-8 -*-

class ImportAddMetricValueUpdate < Card::Migration
  def up
    import_json "add_metric_value_update.json"
  end
end
