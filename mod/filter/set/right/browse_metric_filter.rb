include_set Abstract::BrowseFilterForm
include_set Abstract::MetricFilterFormgroups
include_set Abstract::BookmarkFiltering
include_set Abstract::SdgFiltering

def default_filter_hash
  { name: "" }
end

def default_sort_option
  :bookmarkers
end

def filter_keys
  %i[name wikirate_topic designer project metric_type value_type
     research_policy year bookmark]
end

def target_type_id
  MetricID
end

def filter_class
  MetricFilterQuery
end

def bookmark_type
  :metric
end

format :html do
  def filter_label key
    key == :metric_type ? "Metric type" : super
  end

  def quick_filter_list
    bookmark_quick_filter + topic_quick_filters + project_quick_filters
  end

  def default_year_option
    { "Any Year" => "" }
  end

  def sort_options
    { "Most Companies": :company,
      "Most Answers": :answer }.merge super
  end
end
