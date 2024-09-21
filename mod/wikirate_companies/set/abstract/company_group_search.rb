include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Abstract::DeckorateFiltering
include_set Abstract::BookmarkFiltering
include_set Abstract::BarBoxToggle

def item_type_id
  CompanyGroupID
end

def bookmark_type
  :company_group
end

format do
  def filter_cql_class
    DeckorateFilterCql
  end

  def filter_map
    %i[name topic bookmark]
  end

  def default_filter_hash
    { name: "" }
  end

  def default_sort_option
    "bookmarkers"
  end

  def sort_options
    { "Most #{rate_subjects}": :company }.merge super
  end
end

format :html do
  def quick_filter_list
    bookmark_quick_filter + topic_quick_filters
  end
end
