def virtual?
  true
end

include_set Set::Abstract::Filter

format :html do
  view :core, cache: :never do
    form_tag path(mark: card.cardname.left, view: content_view),
             class: "filter-container slotter sub-content", method: "GET",
             id: "_filter_container", data: { remote: "true" } do
      output [advanced_filter, _render_main_filter]
    end
  end

  view :main_filter, cache: :never do
    wrap_with :div, class: "filter-header" do
      [
        main_filter_form,
        more_filter_options_link
      ]
    end
  end

  # style="display: #{filter_active};"
  def advanced_filter
    if filter_advanced_active?
      advanced_filter_form_wrap
    else
      advanced_filter_placeholder
    end
  end

  def advanced_filter_placeholder
    wrap_with :div, "", id: "_filter_details",
                        class: "filter-details collapse"
  end

  def advanced_filter_form_wrap
    html_class = "filter-details collapse"
    html_class += " in" if filter_advanced_active?
    wrap_with :div, class: html_class, id: "_filter_details" do
      _render_advanced_filter_form
    end
  end

  view :advanced_filter_form, cache: :never do
    advanced_filter_formgroups
  end

  def more_filter_options_link
    button_tag "more filter options",
               situation: "link", type: "button", class: "filter-toggle btn-sm",
               data: { toggle: "collapse",
                       url: path(view: :advanced_filter_form),
                       target: "#_filter_details",
                       collapse_text_in: "fewer filter options",
                       collapse_text_out: "more filter options" }
  end

  def content_view
    :data
  end

  def filter_button_formgroup
    button_formgroup do
      [filter_submit_button, filter_reset_button]
    end
  end

  def filter_submit_button
    filter_icon = fa_icon("search").html_safe
    button_tag(filter_icon, situation: "default", disable_with: "Filtering")
  end

  def filter_reset_button
    html_class = "slotter btn btn-default margin-8"
    html_class += filter_active? ? " show" : " hide"
    link_to_card card.cardname.left, "Reset",
                 path: { view: content_view },
                 remote: true, class: html_class
  end
end
