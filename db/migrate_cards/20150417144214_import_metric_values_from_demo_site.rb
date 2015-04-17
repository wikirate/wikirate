# -*- encoding : utf-8 -*-

class ImportMetricValuesFromDemoSite < Card::Migration
  def up
    import_json "metric_values_from_demo_site.json"
    
  end
end
