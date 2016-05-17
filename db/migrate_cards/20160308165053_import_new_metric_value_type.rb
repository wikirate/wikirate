# -*- encoding : utf-8 -*-
# new metric value type import
class ImportNewMetricValueType < Card::Migration
  def up
    import_json "new_metric_value_type.json"
  end
end
