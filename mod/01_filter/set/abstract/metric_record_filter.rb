include_set Abstract::SpecialFilterForm

format :html do
  def main_filter_form
    wrap_with :div, class: "input-and-button" do
      [
        main_filter_inputs,
        main_filter_buttons
      ]
    end
  end

  def main_filter_inputs
    content_tag :div, class: "margin-12" do
      main_filter_formgroups
    end
  end

  def main_filter_buttons
    content_tag :div, class: "filter-buttons" do
      filter_button_formgroup
    end
  end

  def filter_form_body_content
    <<-HTML
      <h4>#{filter_body_header}</h4>
      <div class="margin-12 sub-content">
          #{filter_fields filter_categories}
      </div>
      <h4>Answer</h4>
    HTML
  end
end
