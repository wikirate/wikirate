include_set Abstract::FilterForm

format :html do
  def filter_categories
    %w(metric wikirate_topic research_policy metric_type)
  end

  def content_view
    :metric_tab
  end

  def filter_form_content
    output(
      [
        wrap_with(:h4, "Metric"),
        wrap_with(:div, metric_filter_fields, class: "margin-12 sub-content"),
        wrap_with(:h4, "Answer"),
        wrap_with(:div, other_filter_fields, class: "margin-12"),
        wrap_with(:div, _optional_render_filter_button_formgroup,
                  class: "margin-12")
      ]
    )
  end

  def metric_filter_fields
    [
      _optional_render(:name_formgroup),
      _optional_render(:wikirate_topic_formgroup),
      _optional_render(:research_policy_formgroup),
      _optional_render(:importance_formgroup),
      _optional_render(:metric_type_formgroup)
    ]
  end

  def other_filter_fields
    [
      _optional_render_metric_value_formgroup,
      _optional_render_year_formgroup,
      content_tag(:hr),
      _optional_render_sort_formgroup
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

  def sort_option_default
    "upvoted"
  end
end
