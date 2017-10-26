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
  view :core, cache: :never do
    filter_fields true
  end

  def filter_label field
    field.to_sym == :metric ? "Keyword" : super
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
