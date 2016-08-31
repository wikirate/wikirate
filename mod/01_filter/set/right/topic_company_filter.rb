include_set Abstract::FilterForm

format :html do
  def view_caching?
    false
  end

  def filter_categories
    %w(name)
  end

  def content_view
    :company_tab
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
    args[:title] = "Company"
  end

  def metric_filter_fields args
    [
      _optional_render(:name_formgroup, args),
      _optional_render(:sort_formgroup, args)
    ]
  end

  def default_sort_formgroup_args args
    args[:sort_options] = {
      "Most Metrics" => "most_metrics",
      "Most Notes" => "most_notes",
      "Most Sources " => "most_sources",
      "Has Overview" => "has_overview"
    }
    args[:sort_option_default] = "most_metrics"
  end
end
