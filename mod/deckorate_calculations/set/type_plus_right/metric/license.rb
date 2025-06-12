include_set Abstract::MetricChild, generation: 1

event :cascade_license, :finalize, changed: :content do
  metric_card.direct_depender_metrics.each do |metric|
    metric.license_card.infer!
  end
end

def infer!
  return false unless metric_card.calculated?

  update! content: compatible(metric_card.direct_dependee_metrics.map(&:license))
end
