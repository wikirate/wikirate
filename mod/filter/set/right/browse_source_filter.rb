# filter interface for "Browse Sources"  page

include_set Type::SearchType
include_set Abstract::BrowseFilterForm

def wql_from_content
  super.merge limit: 15, sort: default_sort_option
end

def filter_class
  SourceFilterQuery
end

def sort_wql
  if current_sort == "recent"
    { sort: "update", dir: "desc" }
  else
    { sort: { right: "*vote count" }, sort_as: "integer", dir: "desc" }
  end
end

def filter_keys
  %i[wikirate_company wikirate_topic report_type]
end

def target_type_id
  SourceID
end

def default_sort_option
  "recent"
end

format :html do
  # view :cited_formgroup, cache: :never do
  #   select_filter :cited, "all"
  # end

  # view :wikirate_company_formgroup, cache: :never do
  #   autocomplete_filter :wikirate_company, :all_companies
  # end

  # view :wikirate_topic_formgroup, cache: :never do
  #   multiselect_filter_type_based :wikirate_topic
  # end

  view :filter_report_type_formgroup, cache: :never do
    select_filter :report_type
  end

  def report_type_options
    type_options :report_type
  end

  def cited_options
    { "All" => "all", "Yes" => "yes", "No" => "no" }
  end

  def sort_options
    super.merge "Most Recent" => "recent"
  end
end

# cardql query to filter sources
class SourceFilterQuery < Card::FilterQuery
  def wikirate_company_wql value
    add_to_wql :right_plus, [{ id: WikirateCompanyID }, { refer_to: value }]
  end

  def wikirate_topic_wql value
    add_to_wql :right_plus, [{ id: WikirateTopicID }, { refer_to: value }]
  end

  def report_type_wql value
    add_to_wql :right_plus, [{ id: ReportTypeID }, { refer_to: value }]
  end
end
