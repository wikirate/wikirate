# -*- encoding : utf-8 -*-

class ImportMetricTypeViewStyles1 < Card::Migration
  def up
    import_cards 'metric_type_view_styles_1.json'
  end
end
