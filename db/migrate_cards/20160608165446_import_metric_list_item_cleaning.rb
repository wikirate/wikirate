# -*- encoding : utf-8 -*-

class ImportMetricListItemCleaning < Card::Migration
  def up
    import_cards 'metric_list_item_cleaning.json'
  end
end
