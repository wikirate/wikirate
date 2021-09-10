# filter interface for "Browse Sources" page

include_set Type::SearchType
include_set Abstract::BrowseFilterForm

def target_type_id
  SourceID
end

format do
  def filter_class
    SourceFilterQuery
  end

  def sort_cql
    if current_sort.to_sym == :title
      { sort: { right: "title" } }
    else
      super
    end
  end

  def sort_options
    { "Recently Added": :create, "Title": :title, "Most Answers": :answer }
  end

  def default_sort_option
    "create"
  end

  def filter_keys
    %i[wikirate_title wikirate_topic report_type year wikirate_link]
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
    text_filter :wikirate_link
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
    return unless value.present?
    add_to_cql :right_plus, [WikirateLinkID, { content: [:match, value] }]
  end

  def wikirate_title_cql value
    return unless value.present?
    add_to_cql :right_plus, [WikirateTitleID, { content: [:match, value] }]
  end

  def wikirate_company_cql value
    return unless value.present?
    add_to_cql :right_plus, [WikirateCompanyID, { refer_to: { match: value } }]
  end

  def report_type_cql value
    add_to_cql :right_plus, [ReportTypeID, { refer_to: value }]
  end

  def year_cql value
    add_to_cql :right_plus, [YearID, { refer_to: value }]
  end
end
