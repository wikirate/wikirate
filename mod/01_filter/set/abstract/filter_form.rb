def virtual?
  true
end

format :html do
  include Set::Abstract::Filter::HtmlFormat
  def filter_categories
    []
  end

  def filter_active?
    Env.params.keys.any? { |key| filter_categories.include? key }
  end

  def content_view
    :content_left_col
  end

  view :filter_button_formgroup do
    button_formgroup { [filter_button, reset_filter_button] }
  end

  def filter_button
    button_tag "Filter", situation: "primary", disable_with: "Filtering"
  end

  def reset_filter_button
    link_to_card card.cardname.left, "Reset",
                 path: { view: content_view },
                 remote: true, class: "slotter btn btn-default margin-8"
  end

  def default_filter_header _args
    voo.title ||= "Filter & Sort"
  end

  view :filter_header do
    wrap_with :div, class: "filter-header" do
      [filter_icon, voo.title, filter_toggle]
    end
  end

  def filter_icon
    wrap_with :span, "", class: "glyphicon glyphicon-filter"
  end

  def filter_toggle
    wrap_with(:span, class: "filter-toggle") do
      wrap_with :span, "", class: "glyphicon glyphicon-triangle-right"
    end
  end

  view :core do
    wrap_with :div, class: "filter-container" do
      [_render_filter_header, filter_details]
    end
  end

  def filter_details
    display = filter_active? ? "block" : "none" # FIXME: inline css!
    wrap_with :div, filter_form_tag, class: "filter-details",
                                     style: "display: #{display};"
  end

  def filter_form_tag
    wrap_with(
      :form, filter_form_content,
      action: "/#{card.cardname.left_name.url_key}?view=#{content_view}",
      method: "GET", class: "slotter", "data-remote" => "true"
    )
  end

  def filter_form_content
    "fill me"
  end
end
