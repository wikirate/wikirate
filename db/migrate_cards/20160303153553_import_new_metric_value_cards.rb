# -*- encoding : utf-8 -*-

class ImportNewMetricValueCards < Card::Migration
  def up
    import_json "new_metric_value_cards.json"
  end
end
