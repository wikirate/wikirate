include_set Abstract::BrowseFilterForm

def filter_keys
  %i[name project wikirate_topic]
end

def filter_class
  CompanyFilterQuery
end

def default_sort_option
  "metric"
end

format :html do
  def sort_options
    {
      "Alphabetical" => "name",
      "Most Metrics" => "metric",
      "Most Topics" => "topic"
    }
  end
end
