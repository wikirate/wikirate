def key_type_id
  WikirateCompanyID
end

def filter_by_key company
  return true unless (filter = company_filter)
  filter.include? company
end

def filter_by_values values
  filter_by_value(values) &&
    filter_by_year(values)
end

private

def company_filter
  filter = fetch_params params_keys
  return unless filter.present?
  Card.search search_wql(WikirateCompanyID, filter, params_keys, "name")
end
