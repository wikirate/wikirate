include_set Abstract::BrowseFilterForm

def filter_keys
  %i[name project company_group]
end

def filter_class
  CompanyFilterQuery
end

def default_sort_option
  "answer"
end

def default_filter_hash
  { name: "" }
end

def target_type_id
  WikirateCompanyID
end

format :html do
  def sort_options
    { "Most Answers": :answer,
      "Most Metrics": :metric }.merge super
  end
end
