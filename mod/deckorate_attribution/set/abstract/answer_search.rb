include_set Abstract::AttributableSearch

format :html do
  view :attribution_alert_detail, wrap: :slot, template: :haml, cache: :never

  def noncommercial_designers
    noncoms = noncommercial_metric_ids
    return [] unless noncoms.present?

    Metric.where(metric_id: noncoms).select(:designer_id).distinct.pluck(:designer_id)
  end

  def noncommercial_metric_ids
    metric_ids_in_results & all_noncommercial_metric_ids
  end

  def metric_ids_in_results
    clean_relation.unscope(:order).select(:metric_id).distinct.pluck(:metric_id)
  end

  def all_noncommercial_metric_ids
    Card.search type: :metric, right_plus: [:license, { match: "NC" }], return: :id
  end
end