# -*- encoding : utf-8 -*-

class ImportMultiMetricFeature1 < Card::Migration
  def up
    import_json "multi_metric_feature_1.json"
  end
end
