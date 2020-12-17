event :update_metric_lookup_hybrid, :finalize, changed: :content do
  ::Metric.find_by_card_id(left_id).refresh :hybrid unless left.action == :create
end

format :html do
  view :unknown do
    "No"
  end
end
