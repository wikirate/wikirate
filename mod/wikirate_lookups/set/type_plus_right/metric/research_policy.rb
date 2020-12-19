event :update_metric_lookup_policy_id, :finalize, changed: :content do
  ::Metric.for_card(left_id).refresh :policy_id unless left.action == :create
end
