include_set Abstract::MetricChild, generation: 1
include_set Abstract::StewardPermissions
include_set Abstract::PublishableField
include_set Abstract::SingleItem
include_set Abstract::LookupField

def ok_item_types
  :assessment
end

def lookup_columns
  :policy_id
end

format :html do
  def input_type
    :select
  end
end
