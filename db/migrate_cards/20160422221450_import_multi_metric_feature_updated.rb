# -*- encoding : utf-8 -*-

class ImportMultiMetricFeatureUpdated < Card::Migration
  def up
    import_json 'multi_metric_feature_updated.json'
  end
end
