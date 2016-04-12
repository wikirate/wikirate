# -*- encoding : utf-8 -*-

class ImportMetricTypeStructureWithValueType < Card::Migration
  def up
    import_json 'metric_type_structure_with_value_type.json'
  end
end
