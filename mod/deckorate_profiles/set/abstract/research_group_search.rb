include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Abstract::DeckorateFiltering
include_set Abstract::BookmarkFiltering
include_set Abstract::BarBoxToggle

def item_type_id
  ResearchGroupID
end

def bookmark_type
  :research_group
end

format do
  def filter_cql_class
    DeckorateFilterCql
  end

  def sort_options
    { "Most Researchers": :researcher, "Most Projects": :project }.merge super
  end

  def default_sort_option
    "researcher"
  end

  def filter_map
    %i[name topic bookmark]
  end

  def default_filter_hash
    { name: "" }
  end
end

format :html do
  def quick_filter_list
    bookmark_quick_filter + topic_quick_filters
  end
end
