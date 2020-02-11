include_set Abstract::BrowseFilterForm
include_set Abstract::BookmarkFiltering

# FilterQuery class for company groups
class CompanyGroupFilterQuery < Card::FilterQuery
  include WikirateFilterQuery
end

def filter_keys
  %i[name bookmark]
end

def default_filter_hash
  { name: "" }
end

def target_type_id
  Card::CompanyGroupID
end

def filter_class
  CompanyGroupFilterQuery
end

def default_sort_option
  "bookmarkers"
end

format :html do
  def sort_options
    { "Most #{rate_subjects}": :company }.merge super
  end
end
