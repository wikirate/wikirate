include_set Abstract::MetricRecordFilter

def filter_keys
  %w[metric_value year]
end

def advanced_filter_keys
  %w[metric wikirate_topic project research_policy importance metric_type]
end

def default_sort_option
  :importance
end

format :html do
  def filter_labels field
    field.to_sym == :metric ? "Keyword" : super
  end

  def filter_body_header
    "Metric"
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
      "Importance to Community (net votes)" => :importance,
      "Metric Designer (Alphabetical)" => :metric_name,
      "Metric Title (Alphabetical)" => :title_name,
      "Recently Updated" => :updated_at
    }
  end
end
