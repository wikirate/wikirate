def key_type_id
  WikirateCompanyID
end

def filter_by_key key
  filter_by_company key
end

def filter_by_company company
  return true unless (filter = company_filter)
  filter.include? company
end

private

def company_filter
  filter = fetch_params params_keys
  return unless filter.present?
  Card.search search_wql(WikirateCompanyID, filter, params_keys, "name")
end
