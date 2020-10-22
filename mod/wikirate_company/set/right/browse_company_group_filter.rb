include_set Abstract::BrowseFilterForm
include_set Abstract::BookmarkFiltering

def target_type_id
  Card::CompanyGroupID
end

# FilterQuery class for company groups
class CompanyGroupFilterQuery < Card::FilterQuery
  include WikirateFilterQuery
end

format do
  def filter_class
    CompanyGroupFilterQuery
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

  def quick_filter_list
    bookmark_quick_filter + topic_quick_filters
  end
end
