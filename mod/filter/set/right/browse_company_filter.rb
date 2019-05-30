include_set Abstract::BrowseFilterForm

def filter_keys
  %i[name project wikirate_topic]
end

def filter_class
  CompanyFilterQuery
end

def default_sort_option
  "answer"
end

def default_filter_option
  { name: "" }
end

format :html do
  def sort_options
    { "Most Answers": :answer,
      "Most Metrics": :metric,
      "Most Topics": :topic }.merge super
  end
end
