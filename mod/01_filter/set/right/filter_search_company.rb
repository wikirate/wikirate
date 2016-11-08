include_set Abstract::BrowseFilterForm

def filter_keys
  %w(name industry)
end

def advanced_filter_keys
  %w(project wikirate_topic)
end

def wql_by_wikirate_topic wql, topic
  return unless topic.present?
  wql[:found_by] = "#{topic}+#{Card[:wikirate_company].name}"
end

format :html do
  def sort_options
    super.merge "Most Metrics" => "metric",
                "Most Topics" => "topic"
  end

  def default_sort_option
    "metric"
  end
end
