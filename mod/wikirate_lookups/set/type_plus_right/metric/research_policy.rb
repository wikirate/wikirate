event :update_metric_lookup_policy_id, :finalize, changed: :content do
  ::Metric.where(metric_id: left_id).refresh :policy_id unless left.action == :create
end
