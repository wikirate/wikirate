# filter interface for "Browse Datasets" page

include_set Type::SearchType
include_set Abstract::BrowseFilterForm
include_set Abstract::BookmarkFiltering
include_set Abstract::SdgFiltering

def target_type_id
  DatasetID
end

format do
  def filter_class
    DatasetFilterQuery
  end

  def default_sort_option
    "create"
  end

  def filter_keys
    %i[name wikirate_status wikirate_topic bookmark]
  end

  def default_filter_hash
    { name: "", wikirate_status: "Active" }
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

  view :filter_wikirate_status_formgroup, cache: :never do
    select_filter :wikirate_status, "Active"
  end

  def wikirate_status_options
    %w[Active Inactive]
  end
end

# cql query to filter sources
class DatasetFilterQuery < Card::FilterQuery
  include WikirateFilterQuery

  def wikirate_status_cql value
    return unless value.present?
    add_to_cql :right_plus, [WikirateStatusID, { refer_to: value }]
  end
end
