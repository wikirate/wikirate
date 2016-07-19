# -*- encoding : utf-8 -*-

class ImportMetricFilterUi < Card::Migration
  def up
    import_cards 'metric_filter_ui.json'
  end
end
