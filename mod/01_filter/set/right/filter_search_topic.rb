include_set Abstract::BrowseFilterForm
def default_sort_by_key
  "metric"
end

def filter_keys
  %w(name)
end

def advanced_filter_keys
  %w(metric project wikirate_company)
end

def target_type_id
  WikirateTopicID
end

def wql_by_metric wql, metric
  return unless metric.present?
  wql[:referred_to_by] ||= []
  wql[:referred_to_by].push left: { name: metric }, right: "topic"
end

def wql_by_wikirate_company wql, company
  return unless company.present?
  wql[:found_by] = "#{company}+topic"
end

def wql_by_project wql, project
  return unless project.present?
  wql[:referred_to_by] ||= []
  wql[:referred_to_by].push left: { name: project }, right: "topic"
end

format :html do
  def sort_options
    {
      "Alphabetical" => "name",
      "Most Metrics" => "metric",
      "Most Companies" => "company"
    }
  end

  def default_sort_option
    "metric"
  end
end
