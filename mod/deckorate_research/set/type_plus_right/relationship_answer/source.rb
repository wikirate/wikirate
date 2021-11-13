include_set Abstract::MetricChild, generation: 4
include_set Abstract::DesignerPermissions
include_set Abstract::Citation

def company_names
  [company_name, left.related_company]
end
