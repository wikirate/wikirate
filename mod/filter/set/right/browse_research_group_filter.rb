# filter interface for "Browse ResearchGroup" page

include_set Type::SearchType
include_set Abstract::BrowseFilterForm
include_set Abstract::BookmarkFiltering
include_set Abstract::SdgFiltering

def default_sort_option
  "researcher"
end

def filter_keys
  %i[name wikirate_topic bookmark]
end

def default_filter_hash
  { name: "" }
end

def target_type_id
  ResearchGroupID
end

def filter_class
  ResearchGroupFilterQuery
end

format :html do
  def sort_options
    { "Most Researchers": :researcher, "Most Projects": :project }.merge super
  end

  def quick_filter_list
    bookmark_quick_filter + topic_quick_filters
  end
end

class ResearchGroupFilterQuery < FilterQuery
  include WikirateFilterQuery
end
