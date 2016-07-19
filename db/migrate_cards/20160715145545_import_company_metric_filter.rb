# -*- encoding : utf-8 -*-

class ImportCompanyMetricFilter < Card::Migration
  def up
    import_cards 'company_metric_filter.json'
  end
end
