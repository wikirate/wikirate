include_set Abstract::BrowseFilterForm

class CompanyFilter < Abstract::FilterQuery::Filter
  def wikirate_topic_wql value
    add_to_wql :found_by, value.to_name.trait(:wikirate_company)
  end
end

def filter_keys
  %w(name industry)
end

def advanced_filter_keys
  %w(project wikirate_topic)
end

def filter_class
  CompanyFilter
end

format :html do
  def sort_options
    {
      "Alphabetical" => "name",
      "Most Metrics" => "metric",
      "Most Topics" => "topic"
    }
  end

  def default_sort_option
    "metric"
  end
end
