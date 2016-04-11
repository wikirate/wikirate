# -*- encoding : utf-8 -*-

class ImportFormulaMetric < Card::Migration
  def up
    import_json "formula_metric.json"
  end
end
