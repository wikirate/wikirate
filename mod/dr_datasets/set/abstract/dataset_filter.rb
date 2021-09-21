# filter interface for Data Sets

include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Abstract::BrowseFilterForm
include_set Abstract::BookmarkFiltering
include_set Abstract::SdgFiltering

def target_type_id
  DatasetID
end

def bookmark_type
  :dataset
end

format do
  def filter_class
    WikirateFilterQuery
  end

  def default_sort_option
    "create"
  end

  def filter_keys
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
      "Most Companies": :company }
  end
end

format :html do
  def quick_filter_list
    bookmark_quick_filter + topic_quick_filters
  end
end
