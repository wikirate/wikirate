include_set Abstract::MetricChild, generation: 1

event :cascade_license, :finalize, changed: :content do
  Auth.as_bot do
    cascade_calculated_metric_licenses
    cascade_dataset_licenses
  end
end

# used by calculated metrics to infer license from its inputs
def infer
  return false unless metric_card.calculated?

  update content: compatible(metric_card.direct_dependee_metrics.map(&:license))
end

def ok_to_delete?
  metric_card&.steward?
end

private

def cascade_calculated_metric_licenses
  metric_card.direct_depender_metrics.each do |metric|
    metric.license_card.infer
  end
end

def cascade_dataset_licenses
  metric_card.dataset_card.item_cards.each do |dataset|
    dataset.license_card.infer
  end
end
