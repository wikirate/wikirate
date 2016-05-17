# -*- encoding : utf-8 -*-

class ImportNewMetricCompanyLayout < Card::Migration
  def up
    import_json "new_metric_company_layout.json"
  end
end
