include_set Abstract::AllValues

format do
  def page_link_params
    [:name, :industry, :project, :year, :value]
  end
end

def key_type_id
  WikirateCompanyID
end

def key_type
  :company
end

def filter_by_key key
  filter_by_company key
end

def company_filter
  filter = fetch_params params_keys
  return unless filter.present?
  Card.search search_wql(WikirateCompanyID, filter, params_keys, "name")
end

def filter_by_company company
  return true unless (filter = company_filter)
  filter.include? company
end
