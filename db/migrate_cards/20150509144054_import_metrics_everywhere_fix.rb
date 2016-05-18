# -*- encoding : utf-8 -*-

class ImportMetricsEverywhereFix < Card::Migration
  def up
    import_json "metrics_everywhere_fix.json"
  end
end
