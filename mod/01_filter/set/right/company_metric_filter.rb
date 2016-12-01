include_set Abstract::MetricRecordFilter

def advanced_filter_keys
  %w(metric wikirate_topic research_policy importance metric_type)
end

def filter_keys
  %w(metric_value year)
end

def default_sort_option
  "upvoted"
end

format :html do
  def content_view
    :metric_tab
  end

  def filter_body_header
    "Metric"
  end

  def filter_labels field
    field.to_sym == :metric ? "Keyword" : super
  end

  def advanced_filter_form
    output [
             advanced_filter_formgroups,
             "<hr/>",
             _render_sort_formgroup
           ]
  end

  def sort_options
    {
      "Importance to Community (up-voted by community)" => "upvoted",
      "Metric Designer (Alphabetical)" => "metric_designer",
      "Metric Title (Alphabetical)" => "metric_title",
      "Recently Updated" => "recent",
      "Most Values" => "value"
    }
  end
end
