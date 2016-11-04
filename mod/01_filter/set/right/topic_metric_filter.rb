include_set Abstract::FilterForm

format :html do
  def view_caching?
    false
  end

  def filter_categories
    %w(name research_policy metric_type)
  end

  def content_view
    :metric_tab
  end

  def filter_form_content args
    <<-HTML
      <div class="margin-12 sub-content"> #{metric_filter_fields(args).join} </div>
      <div class="filter-buttons">
        #{_optional_render :button_formgroup, args}
      </div>
    HTML
  end

  def default_name_formgroup_args args
    voo.title = "Metric Name"
  end

  def metric_filter_fields
    [
      _optional_render_name_formgroup,
      _optional_render_research_policy_formgroup,
      _optional_render_metric_type_formgroup,
      _optional_render_sort_formgroup
    ]
  end

  def sort_options
    {
      "Importance to Community (up-voted by community)" => "upvoted",
      "Most Company" => "company_number",
      "Metric Designer (Alphabetical)" => "metric_designer",
      "Metric Title (Alphabetical)" => "metric_title"
    }
  end

  def sort_option_default
    "upvoted"
  end
end
