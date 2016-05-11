# -*- encoding : utf-8 -*-

class ImportMetricTypeViewStyles < Card::Migration
  def up
    import_cards 'metric_type_view_styles.json'
  end
end
