include_set Abstract::FilterForm
include_set Abstract::MetricRecordFilter

format :html do
  def filter_categories
    %w(keyword wikirate_topic research_policy importance metric_type)
  end

  def filter_body_header
    "Metric"
  end

  def other_filter_fields args
    [
      _optional_render(:metric_value_formgroup, args),
      _optional_render(:year_formgroup, args),
      content_tag(:hr),
      _optional_render(:sort_formgroup, args)
    ]
  end

  def default_sort_formgroup_args args
    args[:sort_options] = {
      "Importance to Community (up-voted by community)" => "upvoted",
      "Metric Designer (Alphabetical)" => "metric_designer",
      "Metric Title (Alphabetical)" => "metric_title",
      "Recently Updated" => "recent",
      "Most Values" => "value"
    }
    args[:sort_option_default] = "upvoted"
  end
end
