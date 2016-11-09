def virtual?
  true
end

include_set Set::Abstract::Filter

format :html do
  view :core do |args|
    form_tag path(mark: card.cardname.left, view: content_view),
             class: "filter-container slotter", id: "_filter_container",
             method: "GET", data: { remote: "true" } do
      output [
               _render_advanced_filter,
               _render_main_filter
             ]
    end
  end

  view :main_filter do
    wrap_with :div, class: "filter-header" do
      [
        main_filter_form,
        more_filter_options_link
      ]
    end
  end

  # style="display: #{filter_active};"
  view :advanced_filter do |args|
    html_class = "filter-details collapse"
    html_class += " in" if filter_advanced_active?
    wrap_with :div, class: html_class, id: "_filter_details" do
      advanced_filter_form
    end
  end

  def advanced_filter_form
     advanced_filter_formgroups
  end

  def more_filter_options_link
    button_tag("more filter options",
               situation: "link",
               class: " filter-toggle btn-sm",
               type: "button",
               data: {
                 toggle: "collapse",
                 target: "#_filter_details",
                 collapseintext: "fewer filter options",
                 collapseouttext: "more filter options"
               })
  end

  def content_view
    :data
  end

  def default_button_formgroup_args args
    filter_icon = fa_icon("search").html_safe
    args[:buttons] = [
      button_tag(filter_icon, situation: "default", disable_with: "Filtering"),
      button_formgroup_reset_button
    ].join
  end

  def button_formgroup_reset_button
    html_class = "slotter btn btn-default margin-8"
    html_class += filter_active? ? " show" : " hide"
    link_to_card card.cardname.left, "Reset",
                 path: { view: content_view },
                 remote: true, class: html_class
  end
end
