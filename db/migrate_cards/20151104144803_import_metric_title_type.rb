# -*- encoding : utf-8 -*-

class ImportMetricTitleType < Card::Migration
  def up
    import_json "metric_title_type.json"
    metric_title_type_card = Card["Metric Title"]
    all_metrics = Card.search type_id: Card::MetricID
    all_metrics.each do |metric|
      metric_title_card = metric.right
      metric_title_card.update_column(:type_id, metric_title_type_card.id)
    end
  end
end
