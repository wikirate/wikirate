# -*- encoding : utf-8 -*-

class ImportMetricMigration < Wagn::Migration
  def up
    import_json "metric_migration.json"
    
  end
end
