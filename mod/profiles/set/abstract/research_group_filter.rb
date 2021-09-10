include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Abstract::BrowseFilterForm
include_set Abstract::BookmarkFiltering
include_set Abstract::SdgFiltering

def target_type_id
  ResearchGroupID
end

def bookmark_type
  :research_group
end

format do
  def filter_class
    ResearchGroupFilterQuery
  end

  def sort_options
    { "Most Researchers": :researcher, "Most Projects": :project }.merge super
  end

  def default_sort_option
    "researcher"
  end

  def filter_keys
    %i[name wikirate_topic bookmark]
  end

  def default_filter_hash
    { name: "" }
  end
end

format :html do
  def quick_filter_list
    bookmark_quick_filter + topic_quick_filters
  end

  view :titled_content do
    [field_nest(:description), render_add_button, render_filtered_content]
  end
end

class ResearchGroupFilterQuery < FilterQuery
  include WikirateFilterQuery
end
