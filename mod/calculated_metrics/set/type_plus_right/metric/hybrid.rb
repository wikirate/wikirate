event :update_metric_lookup_hybrid, :finalize, changed: :content do
  ::Metric.for_card(left_id).refresh :hybrid unless left.action == :create
end

format :html do
  view :unknown do
    "No"
  end
end
