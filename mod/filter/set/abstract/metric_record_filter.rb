include_set Abstract::SpecialFilterForm

format :html do
  def content_view
    :content
  end

  def main_filter_form
    wrap_with :div, class: "input-and-button" do
      [
        main_filter_inputs,
        main_filter_buttons
      ]
    end
  end

  def main_filter_inputs
    wrap_with :div, class: "margin-12" do
      main_filter_formgroups
    end
  end

  def main_filter_buttons
    wrap_with :div, class: "filter-buttons" do
      filter_button_formgroup
    end
  end

  def filter_form_body_content
    output(
      [
        wrap_with(:h4, filter_body_header),
        wrap_with(:div, class: "margin-12 sub-content") do
          filter_fields filter_categories
        end,
        wrap_with(:h4, "Answer")
      ]
    )
  end
end
