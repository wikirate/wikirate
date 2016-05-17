# -*- encoding : utf-8 -*-

class ImportMetricValueInterfaceCardsV1 < Card::Migration
  def up
    import_json "metric_value_interface_cards_v1.json"
  end
end
