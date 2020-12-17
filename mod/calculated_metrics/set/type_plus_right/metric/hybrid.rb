event :update_metric_lookup_hybrid, :finalize, changed: :content do
  ::Metric.where(metric_id: left_id).refresh :hybrid unless left.action == :create
end

format :html do
  view :unknown do
    "No"
  end
end
