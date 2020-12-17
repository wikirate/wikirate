event :update_metric_lookup_metric_type_id, :finalize, changed: :content do
  ::Metric.where(metric_id: left_id).refresh :metric_type_id unless left.action == :create
end
