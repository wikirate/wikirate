# -*- encoding : utf-8 -*-

class ImportNewMetricValueType < Card::Migration
  def up
    import_json 'new_metric_value_type.json'
  end
end
