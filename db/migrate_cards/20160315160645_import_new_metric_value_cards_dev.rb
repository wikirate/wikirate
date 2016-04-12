# -*- encoding : utf-8 -*-

class ImportNewMetricValueCardsDev < Card::Migration
  def up
    import_json 'new_metric_value_cards_dev.json'
  end
end
