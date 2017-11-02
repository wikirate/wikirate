include_set Abstract::RightFilterForm

def filter_keys
  %i[metric_value year]
end

def advanced_filter_keys
  %i[metric wikirate_topic project research_policy importance metric_type]
end

def default_sort_option
  :importance
end

def default_filter_option
  { year: :latest, metric_value: :exists }
end

format :html do
  def filter_label field
    field.to_sym == :metric_type ? "Metric type" : super
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
