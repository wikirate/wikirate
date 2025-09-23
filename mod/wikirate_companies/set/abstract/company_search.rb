include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Abstract::DeckorateFiltering
include_set Abstract::BookmarkFiltering
include_set Abstract::CommonFilters
include_set Abstract::AnswerFilters
include_set Abstract::CompanyFilters
include_set Abstract::BarBoxToggle
include_set Abstract::JsonldSupport

def bookmark_type
  :company
end

def item_type_id
  CompanyID
end

def filter_cql_class
  CompanyFilterCql
end

format do
  delegate :filter_cql_class, to: :card

  def default_sort_option
    "id"
  end

  def default_filter_hash
    { name: "" }
  end

  def sort_options
    { "Most Data Points": :answer, "Most Metrics": :metric }.merge super
  end

  def filter_map
    shared_company_filter_map.unshift key: :name, label: "Company Name", open: true
  end
end

format :csv do
  view :titles do
    super() + Card.new(type: :company).simple_field_names
  end
end

format :html do
  def default_sort_option
    "answer"
  end

  # def quick_filter_list
  #   bookmark_quick_filter + company_group_quick_filters + dataset_quick_filters
  # end
end
