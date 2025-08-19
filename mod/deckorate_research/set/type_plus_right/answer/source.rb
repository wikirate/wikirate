include_set Abstract::MetricChild, generation: 3
include_set Abstract::StewardPermissions
include_set Abstract::LookupField
include_set Abstract::PublishableField
include_set Abstract::Citation

def ok_item_types
  :source
end

def lookup_columns
  %i[source_count source_url]
end

def company_names
  [company_name]
end
