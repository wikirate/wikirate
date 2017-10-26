include_set Abstract::BrowseFilterForm

class TopicFilterQuery < Card::FilterQuery
  def metric_wql metric
    add_to_wql :referred_to_by, left: { name: metric }, right: "topic"
  end

  def project_wql project
    add_to_wql :referred_to_by, left: { name: project }, right: "topic"
  end

  def wikirate_company_wql company
    add_to_wql :found_by, "#{company}+topic"
  end
end

def default_sort_by_key
  "metric"
end

def filter_keys
  %i[name]
end

def advanced_filter_keys
  %i[metric project wikirate_company]
end

def target_type_id
  WikirateTopicID
end

def filter_class
  TopicFilterQuery
end

def default_sort_option
  "metric"
end

format :html do
  def sort_options
    {
      "Alphabetical" => "name",
      "Most Metrics" => "metric",
      "Most Companies" => "company"
    }
  end
end
