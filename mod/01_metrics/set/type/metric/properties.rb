format :html do
  view :metric_properties do |args|
    props = {}
    props["Designed By"] = _render_designer_info.html_safe
    props["Scored By"] =
      _render_scorer_info.html_safe if card.metric_type_codename == :score
    props["Metric Type"] =
      field_subformat(:metric_type)._render_content items: { view: :name }
    if card.researched?
      props["Value Type"] = content_tag(:div, _render_value_type_detail(args))
      props["Research Policy"] = nest(card.research_policy_card,
                                      view: :content,
                                      items: { view: :name })
      props["Report Type"] = nest(card.report_type_card,
                                  view: :content,
                                  items: { view: :name })
      props["Projects"] =
        nest(card.project_card, view: :content,
                                items: {  view: "content",
                                          structure: "list item" })
    end
    # FIXME use labeled view
    props["Topics"] =
      field_subformat(:wikirate_topic)._render_content items: { view: :link }
    table props, class: "metric-properties"
  end
end
