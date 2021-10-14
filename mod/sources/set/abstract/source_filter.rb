# Source filtering

include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Abstract::BrowseFilterForm

def target_type_id
  SourceID
end

format do
  def filter_class
    SourceFilterQuery
  end

  def sort_cql
    return super unless current_sort.to_sym == :title

    { sort: { right: "title" } }
  end

  def sort_options
    { "Recently Added": :create, "Title": :title, "Most Answers": :answer }
  end

  def default_sort_option
    "create"
  end

  def filter_keys
    %i[wikirate_title wikirate_topic report_type year wikirate_link company_name]
  end

  def default_filter_hash
    { wikirate_title: "" }
  end
end

format :html do
  view :filter_wikirate_title_formgroup, cache: :never do
    text_filter :wikirate_title
  end

  view :filter_wikirate_link_formgroup, cache: :never do
    text_filter :wikirate_link, "",  placeholder: "https://"
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
class SourceFilterQuery < WikirateFilterQuery
  def wikirate_link_cql value
    matching_field WikirateLinkID, value
  end

  def wikirate_title_cql value
    matching_field WikirateTitleID, value
  end

  def company_name_cql value
    matching_field WikirateCompanyID, value
  end

  def report_type_cql value
    add_to_cql :right_plus, [ReportTypeID, { refer_to: value }]
  end

  def year_cql value
    add_to_cql :right_plus, [YearID, { refer_to: value }]
  end

  private

  def matching_field field_id, value
    add_to_cql :right_plus, [field_id, { content: [:match, value] }] if value.present?
  end
end
