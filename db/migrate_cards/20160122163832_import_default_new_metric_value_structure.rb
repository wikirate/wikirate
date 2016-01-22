# -*- encoding : utf-8 -*-

class ImportDefaultNewMetricValueStructure < Card::Migration
  def up
    import_json 'default_new_metric_value_structure.json'
  end
end
