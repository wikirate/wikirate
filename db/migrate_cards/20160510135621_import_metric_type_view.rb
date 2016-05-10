# -*- encoding : utf-8 -*-

class ImportMetricTypeView < Card::Migration
  def up
    import_json 'metric_type_view.json'
  end
end
