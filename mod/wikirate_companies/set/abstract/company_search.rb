include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Abstract::DeckorateFiltering
include_set Abstract::BookmarkFiltering
include_set Abstract::CommonFilters
include_set Abstract::AnswerFilters
include_set Abstract::CompanyFilters

def bookmark_type
  :wikirate_company
end

def target_type_id
  WikirateCompanyID
end

def filter_class
  CompanyFilterQuery
end

format do
  delegate :filter_class, to: :card

  def default_sort_option
    "id"
  end

  def default_filter_hash
    { name: "" }
  end

  def sort_options
    { "Most Answers": :answer, "Most Metrics": :metric }.merge super
  end
end

format :html do
  def filter_map
    shared_company_filter_map.unshift key: :name, open: true
  end

  def default_sort_option
    "answer"
  end

  def quick_filter_list
    bookmark_quick_filter + company_group_quick_filters + dataset_quick_filters
  end
end
