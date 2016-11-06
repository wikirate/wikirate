include_set Abstract::FilterForm
include_set Abstract::FilterUtility
format :html do
  def view_caching?
    false
  end

  def filter_categories
    %w(company industry project)
  end

  def filter_form_content
    <<-HTML
      <h4>Company</h4>
      <div class="margin-12 sub-content"> #{company_filter_fields.join} </div>
      <h4>Metric Answer</h4>
      <div class="margin-12"> #{value_filter_fields.join} </div>
      <div class="filter-buttons">
        #{_optional_render_filter_button_formgroup}
      </div>
    HTML
  end

  def company_filter_fields
    [
      _optional_render_name_formgroup,
      _optional_render_industry_formgroup,
      select_filter(:project, "asc")
    ]
  end

  def value_filter_fields
    [
      _optional_render_year_formgroup,
      _optional_render_metric_value_formgroup
    ]
  end
end
