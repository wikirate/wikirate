# -*- encoding : utf-8 -*-

class ImportMetricFix2 < Card::Migration
  def up
    import_json "metric_fix2.json"
  end
end
