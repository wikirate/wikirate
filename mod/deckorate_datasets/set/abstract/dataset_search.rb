# filter interface for Data Sets

include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set CommonFilters
include_set Abstract::DeckorateFiltering
include_set Abstract::BookmarkFiltering

def item_type_id
  DatasetID
end

def bookmark_type
  :dataset
end

format do
  def filter_cql_class
    WikirateFilterCql
  end

  def default_sort_option
    "create"
  end

  def filter_map
    %i[name wikirate_topic bookmark]
  end

  def default_filter_hash
    { name: "" }
  end

  def sort_options
    { "Most Bookmarked": :bookmarkers,
      "Recently Added": :create,
      "Alphabetical": :name,
      "Most Data Subsets": :data_subsets,
      "Most Metrics": :metric,
      "Most Companies": :company,
      "Most References": :reference }
  end
end

format :html do
  def quick_filter_list
    bookmark_quick_filter + topic_quick_filters
  end
end
