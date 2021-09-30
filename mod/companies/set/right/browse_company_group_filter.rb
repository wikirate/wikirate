include_set Abstract::BrowseFilterForm
include_set Abstract::BookmarkFiltering

def target_type_id
  Card::CompanyGroupID
end

format do
  def filter_class
    WikirateFilterQuery
  end

  def filter_keys
    %i[name wikirate_topic bookmark]
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
