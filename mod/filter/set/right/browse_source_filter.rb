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
  { sort: "create", dir: "desc" }
end

def filter_keys
  %i[wikirate_title wikirate_company wikirate_topic report_type]
end

def default_filter_option
  { wikirate_title: "" }
end

def target_type_id
  SourceID
end

def default_sort_option
  "create"
end

format :html do
  view :sort_formgroup do
    ""
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

  # name is hard (because actual names are source-123412)
  # update is misleading (because field updates don't change card update date)
  # ... seems best not to offer bad options.
  def sort_options
    {}
  end
end

# cardql query to filter sources
class SourceFilterQuery < Card::FilterQuery
  def wikirate_title_wql value
    return unless value.present?
    add_to_wql :right_plus, [WikirateTitleID, { content: [:match, value] }]
  end

  def wikirate_company_wql value
    return unless value.present?
    add_to_wql :right_plus, [WikirateCompanyID, { refer_to: { match: value } }]
  end

  def wikirate_topic_wql value
    add_to_wql :right_plus, [WikirateTopicID, { refer_to: value }]
  end

  def report_type_wql value
    add_to_wql :right_plus, [ReportTypeID, { refer_to: value }]
  end
end
