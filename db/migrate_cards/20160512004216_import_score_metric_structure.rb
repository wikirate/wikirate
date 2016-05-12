# -*- encoding : utf-8 -*-

class ImportScoreMetricStructure < Card::Migration
  def up
    import_cards 'score_metric_structure.json'
  end
end
