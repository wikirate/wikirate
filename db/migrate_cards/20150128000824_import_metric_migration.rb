# -*- encoding : utf-8 -*-

class ImportMetricMigration < Card::Migration
  def up
    Card.create! :name=>'Metric value', :codename=>'metric_value', :type_code=>:cardtype
    import_json "metric_migration.json"

  end
end
