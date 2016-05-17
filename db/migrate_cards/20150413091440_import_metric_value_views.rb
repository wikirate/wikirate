# -*- encoding : utf-8 -*-

class ImportMetricValueViews < Card::Migration
  def up
    import_json "metric_value_views.json"
  end
end
