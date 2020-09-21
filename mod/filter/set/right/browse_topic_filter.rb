include_set Abstract::BrowseFilterForm
include_set Abstract::BookmarkFiltering

class TopicFilterQuery < Card::FilterQuery
  include WikirateFilterQuery

  def metric_cql metric
    add_to_cql :referred_to_by, left: { name: metric }, right: "topic"
  end

  def project_cql project
    add_to_cql :referred_to_by, left: { name: project }, right: "topic"
  end

  def wikirate_company_cql company
    add_to_cql :found_by, "#{company}+topic"
  end
end

def filter_keys
  %i[name bookmark]
end

def default_filter_hash
  { name: "" }
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
    { "Most Metrics": :metric, "Most #{rate_subjects}": :company }.merge super
  end
end
