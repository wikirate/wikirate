include_set Abstract::MetricChild, generation: 1
include_set Abstract::DesignerPermissions
include_set Abstract::PublishableField
include_set Abstract::SingleItem

format :html do
  def input_type
    :multiselect
  end
end
