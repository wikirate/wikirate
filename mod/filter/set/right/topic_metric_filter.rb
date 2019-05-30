include_set Abstract::RightFilterForm
include_set Abstract::FilterFormgroups

def filter_keys
  %i[metric research_policy metric_type]
end

def default_sort_option
  "upvoted"
end

def default_filter_option
  { year: :latest, metric_value: :exists }
end

format :html do
  def content_view
    :metric_tab
  end

  def filter_label field
    field.to_sym == :metric ? "Metric Name" : super
  end

  def sort_options
    {
      "Highest Voted": :upvoted,
      "Most Companies": :company,
      "Metric Designer (Alphabetical)" => "metric_designer",
      "Metric Title (Alphabetical)" => "metric_title"
    }
  end
end
