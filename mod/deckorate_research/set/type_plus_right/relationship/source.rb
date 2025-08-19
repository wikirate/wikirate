include_set Abstract::MetricChild, generation: 4
include_set Abstract::StewardPermissions
include_set Abstract::Citation

def company_names
  [company_name, left.related_company]
end

def stewarded_card
  metric_card
end

