

format :html do
  def basic_properties
    {
      designer:    "Designed By",
      scorer:      "Scored By",
      topic:       "Topics",
      metric_type: "Metric Type"
    }
  end

  def researched_properties
    basic_properties.merge(
      research_policy: "Research Policy",
      report_type:     "Report Type",
      value_type:      "Value Type"
    )
  end

  view :metric_properties do
    table table_properties, class: "metric-properties"
  end

  def table_properties
    props = card.researched? ? researched_properties : basic_properties
    # TODO: above should use set pattern
    props.each_with_object({}) do |(p_name, p_label), p_hash|
      next unless (row_value = send "#{p_name}_property")
      p_hash[p_label] = row_value
      p_hash
    end
  end

  def designer_property
    nest card.metric_designer_card, view: :designer_slot,
                                    show: :menu, hide: :horizontal_menu
  end

  def scorer_property
    return unless card.metric_type_codename == :score
    _render_scorer_info
  end

  def metric_property_nest field, item_view: :name
    field_nest field,  view: :content, show: :menu, items: { view: item_view }
  end

  def topic_property
    metric_property_nest :wikirate_topic, item_view: :link
  end

  def metric_type_property
    field_nest :metric_type, view: :content, items: { view: :name }
  end

  def value_type_property
    wrap_with :div, _render_value_type_detail(show: :menu, hide: :horizontal_menu)
  end

  def research_policy_property
    metric_property_nest :research_policy
  end

  def report_type_property
    metric_property_nest :report_type
  end
end
