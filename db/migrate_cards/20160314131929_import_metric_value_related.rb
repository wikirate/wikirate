# -*- encoding : utf-8 -*-

class ImportMetricValueRelated < Card::Migration
  def up
    import_json "metric_value_related.json"
  end
end
