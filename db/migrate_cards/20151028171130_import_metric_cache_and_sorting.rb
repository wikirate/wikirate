# -*- encoding : utf-8 -*-

class ImportMetricCacheAndSorting < Card::Migration
  def up
    import_json "metric_cache_and_sorting.json"
    
  end
end
