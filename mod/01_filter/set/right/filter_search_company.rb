include_set Abstract::Filter

def default_keys
  %w(name industry)
end

def advance_keys
  %w(project wikirate_topic)
end

def default_sort_by_key
  "metric"
end

def wql_by_wikirate_topic wql, topic
  return unless topic.present?
  wql[:found_by] = "#{topic}+company"
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
