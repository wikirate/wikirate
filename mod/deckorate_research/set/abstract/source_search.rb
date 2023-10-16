# Source filtering

include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Abstract::DeckorateFiltering
include_set Abstract::CommonFilters

def item_type_id
  SourceID
end

format do
  def filter_cql_class
    SourceFilterCql
  end

  def sort_cql
    return super unless current_sort.to_sym == :title

    { sort_by: { right: "title" } }
  end

  def sort_options
    { "Recently Added": :create, "Title": :title, "Most Answers": :answer }
  end

  def default_sort_option
    "create"
  end

  def filter_map
    %i[report_type year wikirate_link company_name]
      .unshift key: :wikirate_title, open: true
  end
end

format :csv do
  view :titles do
    super() + ["Title", "Company", "Year", "Report Type", "Original Link"]
  end
end

format :html do
  {
    wikirate_title: :text,
    wikirate_link: :text,
    report_type: :check
  }.each do |filter_key, filter_type|
    define_method("filter_#{filter_key}_type") { filter_type }
  end

  def filter_report_type_options
    type_options :report_type
  end

  # def year_options
  #   type_options :year, "desc"
  # end
end

# cql for filtering sources
class SourceFilterCql < WikirateFilterCql
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
    value = [:in] + Array.wrap(value)
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
