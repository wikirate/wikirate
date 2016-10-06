include_set Abstract::Filter

format :html do
  view :main_filter_form_content do |args|
    wrap_with :div, class: "input-and-button" do
      [
        main_filter_inputs(args),
        main_filter_buttons(args)
      ]
    end
  end

  def main_filter_inputs args
    content_tag :div, class: "margin-12" do
      filter_fields main_filter_categories, args
    end
  end

  def main_filter_buttons args
    content_tag :div, class: "filter-buttons" do
      _optional_render(:button_formgroup, args).html_safe
    end
  end

  def filter_form_body_content args
    <<-HTML
      <h4>#{filter_body_header}</h4>
      <div class="margin-12 sub-content">
          #{filter_fields filter_categories, arg}
      </div>
      <h4>Answer</h4>
    HTML
  end
end