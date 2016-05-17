# -*- encoding : utf-8 -*-

class ImportMultiMetricFeature < Card::Migration
  def up
    import_json "multi_metric_feature.json"
  end
end
