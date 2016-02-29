# -*- encoding : utf-8 -*-

class ImportNewMetricForm < Card::Migration
  def up
    import_json 'new_metric_form.json'
  end
end
