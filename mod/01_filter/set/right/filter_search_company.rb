include_set Abstract::Filter
include_set Abstract::FilterUtility
def default_keys
  %w(name industry)
end

def advanced_keys
  %w(project wikirate_topic)
end

def default_sort_by_key
  "metric"
end

def wql_by_wikirate_topic wql, topic
  return unless topic.present?
  wql[:found_by] = "#{topic}+#{Card[:wikirate_company].name}"
end

format :html do
  def default_sort_formgroup_args args
    super args
    args[:sort_options].merge!(
      "Most Metrics" => "metric", "Most Topics" => "topic"
    )
    args[:sort_option_default] = "metric"
  end
end
