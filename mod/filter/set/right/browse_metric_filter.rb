include_set Abstract::BrowseFilterForm
include_set Abstract::MetricFilterFormgroups
include_set Abstract::BookmarkFiltering
include_set Abstract::SdgFiltering
include_set Abstract::LookupSearch

def bookmark_type
  :metric
end

def item_type
  "Metric"
end

def filter_class
  MetricQuery
end

def target_type_id
  MetricID
end

format do
  def default_filter_hash
    { name: "" }
  end

  def default_sort_option
    :bookmarkers
  end

  def filter_keys
    %i[name wikirate_topic designer project metric_type value_type
       research_policy bookmark]
  end

  def filter_label key
    key == :metric_type ? "Metric type" : super
  end

  # def default_year_option
  #   { "Any Year" => "" }
  # end

  def sort_options
    { "Most Companies": :company, "Most Answers": :answer }.merge super
  end
end

format :html do
  def export_formats
    [:csv, :json]
  end

  def quick_filter_list
    bookmark_quick_filter + topic_quick_filters + project_quick_filters
  end
end

format :csv do
  view :core do
    rows = search_with_params.map { |ic| nest ic, view: :line }
    rows.unshift(header).join
  end

  def header
    CSV.generate_line MetricImportItem.headers
  end
end
