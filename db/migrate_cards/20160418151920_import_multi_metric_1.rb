# -*- encoding : utf-8 -*-

class ImportMultiMetric1 < Card::Migration
  def up
    import_json 'multi_metric_1.json'
  end
end
