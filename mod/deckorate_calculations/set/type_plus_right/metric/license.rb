include_set Abstract::MetricChild, generation: 1

event :cascade_license, :finalize, content: :changed do
  metric_card.direct_depender_metrics.each do |metric|
    metric
  end
end
