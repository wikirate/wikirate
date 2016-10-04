include_set Abstract::FilterForm
include_set Abstract::FilterUtility
format :html do
  def view_caching?
    false
  end

  def filter_categories
    # name implies 'company' name
    %w(name industry project)
  end

  view :filter_form_header_content do |args|
    wrap_with :div, class: "input-and-button" do
      [
        filter_header_inputs(args),
        filter_header_buttons(args)
      ]
    end
  end

  def filter_header_inputs args
    fields = value_filter_fields(args).join.html_safe
    content_tag(:div, fields, class: "margin-12")
  end

  def filter_header_buttons args
    buttons = _optional_render(:button_formgroup, args).html_safe
    content_tag(:div, buttons, class: "filter-buttons")
  end

  def filter_form_body_content args
    <<-HTML
      <h5>Company Filter</h5>
      <div class="margin-12 sub-content"> #{company_filter_fields(args).join} </div>
      <h5>Metric Answer</h5>
      <!-- <div class="margin-12"> #{value_filter_fields(args).join} </div>
      <div class="filter-buttons">#{_optional_render :button_formgroup, args}</div> -->
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
