# -*- encoding : utf-8 -*-

class ImportMetricValuesFix < Card::Migration
  def up
    import_json "metric_values_fix.json"
    Card.create! :name=>'add value', :codename=>'add_value'
  end
end
