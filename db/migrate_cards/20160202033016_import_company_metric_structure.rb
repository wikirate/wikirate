# -*- encoding : utf-8 -*-

class ImportCompanyMetricStructure < Card::Migration
  def up
    import_json "company_metric_structure.json"
  end
end
