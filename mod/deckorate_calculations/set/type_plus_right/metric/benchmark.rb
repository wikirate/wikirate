include_set Abstract::MetricChild, generation: 1
include_set Abstract::StewardPermissions
include_set Abstract::LookupField

assign_type :toggle

format :html do
  view :unknown do
    "No"
  end
end
