# -*- encoding : utf-8 -*-

class ImportLimitedMetricWql < Card::Migration
  def up
    import_cards 'limited_metric_wql.json'
  end
end
