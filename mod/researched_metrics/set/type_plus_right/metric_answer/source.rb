include_set Abstract::MetricChild, generation: 3
include_set Abstract::DesignerPermissions
include_set Abstract::Citation
include_set Abstract::LookupField

def lookup_columns
  %i[source_count source_url]
end

def company_names
  [company_name]
end
