# -*- encoding : utf-8 -*-

class ImportMetricsEverywhere < Card::Migration
  def up
    import_json "metrics_everywhere.json"
  end
end
