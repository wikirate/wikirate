# -*- encoding : utf-8 -*-

class ImportNewHomepageMetric < Card::Migration
  def up
    import_json "new_homepage_metric.json"
    
  end
end
