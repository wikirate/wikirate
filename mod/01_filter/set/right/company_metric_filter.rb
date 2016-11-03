include_set Abstract::FilterForm

format :html do
  def filter_categories
    %w(metric wikirate_topic research_policy metric_type)
  end

  def content_view
    :metric_tab
  end

  def filter_form_content
    <<-HTML
      <h4>Metric</h4>
      <div class="margin-12 sub-content"> #{metric_filter_fields.join} </div>
      <h4>Answer</h4>
      <div class="margin-12"> #{other_filter_fields.join} </div>
      <div class="filter-buttons">
        #{_optional_render :button_formgroup}
      </div>
    HTML
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
