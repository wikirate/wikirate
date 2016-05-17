# -*- encoding : utf-8 -*-

class ImportMetricFix < Card::Migration
  def up
    import_json "metric_fix.json"
    Card.create! :name=>"add value", :codename=>"add_value"
  end
end
