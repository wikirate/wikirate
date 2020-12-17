include_set Abstract::MetricChild, generation: 1
include_set Abstract::DesignerPermissions

event :update_metric_lookup_unit, :finalize, changed: :content do
  ::Metric.where(metric_id: left_id).refresh :unit unless left.action == :create
end
