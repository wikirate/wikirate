include_set Abstract::FilterForm
include_set Abstract::FilterUtility
format :html do
  def filter_categories
    %w(company industry project)
  end

  def filter_form_content args
    <<-HTML
      <h4>Company</h4>
      <div class="margin-12 sub-content"> #{company_filter_fields(args).join} </div>
      <h4>Metric Answer</h4>
      <div class="margin-12"> #{value_filter_fields(args).join} </div>
      <div class="filter-buttons">#{_optional_render :button_formgroup, args}</div>
    HTML
  end

  def company_filter_fields args
    [
      _optional_render(:name_formgroup, args),
      _optional_render(:industry_formgroup, args),
      select_filter(:project, "asc")
    ]
  end

  def value_filter_fields args
    [
      _optional_render(:year_formgroup, args),
      _optional_render(:metric_value_formgroup, args)
    ]
  end
end
