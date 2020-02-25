# filter interface for "Browse Sources" page

include_set Type::SearchType
include_set Abstract::BrowseFilterForm

def filter_class
  SourceFilterQuery
end

def sort_wql
  if current_sort.to_sym == :title
    { sort: { right: "title" } }
  else
    super
  end
end

def default_sort_option
  "create"
end

def filter_keys
  %i[wikirate_title wikirate_topic report_type year]
end

def default_filter_hash
  { wikirate_title: "" }
end

def target_type_id
  SourceID
end

format :html do
  def sort_options
    { "Recently Added": :create, "Title": :title, "Most Answers": :answer }
  end

  view :filter_wikirate_title_formgroup, cache: :never do
    text_filter :wikirate_title
  end

  view :filter_report_type_formgroup, cache: :never do
    select_filter :report_type
  end

  def report_type_options
    type_options :report_type
  end

  view :filter_year_formgroup, cache: :never do
    select_filter :year
  end

  def year_options
    type_options :year, "desc"
  end
end

# cql query to filter sources
class SourceFilterQuery < FilterQuery
  include WikirateFilterQuery

  def wikirate_title_wql value
    return unless value.present?
    add_to_wql :right_plus, [WikirateTitleID, { content: [:match, value] }]
  end

  def wikirate_company_wql value
    return unless value.present?
    add_to_wql :right_plus, [WikirateCompanyID, { refer_to: { match: value } }]
  end

  def report_type_wql value
    add_to_wql :right_plus, [ReportTypeID, { refer_to: value }]
  end

  def year_wql value
    add_to_wql :right_plus, [YearID, { refer_to: value }]
  end
end
