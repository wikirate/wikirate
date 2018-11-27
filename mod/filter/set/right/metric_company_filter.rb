include_set Abstract::RightFilterForm
include_set Abstract::FilterFormgroups

def filter_keys
  %i[year metric_value]
end

def advanced_filter_keys
  %i[wikirate_company project]
end

def default_filter_option
  { year: :latest, metric_value: :exists }
end

# no sort options because sorting is done by links
# in the header of the table
