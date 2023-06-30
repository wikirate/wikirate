include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Abstract::BookmarkFiltering

def item_type_id
  WikirateTopicID
end

def bookmark_type
  :wikirate_topic
end

format do
  def filter_cql_class
    TopicFilterCql
  end

  def default_sort_option
    "metric"
  end

  def filter_map
    %i[name bookmark]
  end

  def default_filter_hash
    { name: "" }
  end

  def sort_options
    { "Most Metrics": :metric, "Most #{rate_subjects}": :company }.merge super
  end
end

# FilterCql class for topic filtering
class TopicFilterCql < WikirateFilterCql
  def metric_cql metric
    add_to_cql :referred_to_by, left: { name: metric }, right: "topic"
  end

  def dataset_cql dataset
    add_to_cql :referred_to_by, left: { name: dataset }, right: "topic"
  end

  def wikirate_company_cql company
    add_to_cql :found_by, "#{company}+topic"
  end
end
