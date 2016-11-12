include_set Abstract::BrowseFilterForm

class TopicFilter < Abstract::FilterQuery::Filter
  def wikirate_company_wql company
    add_to_wql :found_by, "#{company}+topic"
  end

  def metric_wql metric
    wql[:referred_to_by].push left: { name: metric }, right: "topic"
  end

  def project_wql project
    return unless project.present?
    wql[:referred_to_by] ||= []
    wql[:referred_to_by].push left: { name: project }, right: "topic"
  end
end
def default_sort_by_key
  "metric"
end

def filter_keys
  %w(name)
end

def advanced_filter_keys
  %w(metric project wikirate_company)
end

def filter_class
  TopicFilter
end

def target_type_id
  WikirateTopicID
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
