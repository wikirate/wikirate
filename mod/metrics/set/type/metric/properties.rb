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
    props = card.researched? ? researched_properties : basic_properties
    # TODO: above should use set pattern
    table_props = props.each_with_object({}) do |(p_name, p_label), p_hash|
      next unless (row_value = send "#{p_name}_property")
      p_hash[p_label] = row_value
      p_hash
    end
    table table_props, class: "metric-properties"
  end

  def designer_property
    _render_designer_info
  end

  def scorer_property
    return unless card.metric_type_codename == :score
    _render_scorer_info
  end

  def topic_property
    field_nest :wikirate_topic, view: :content, items: { view: :link }
  end

  def metric_type_property
    field_nest :metric_type, view: :content, items: { view: :name }
  end

  def value_type_property
    wrap_with :div, _render_value_type_detail
  end

  def research_policy_property
    field_nest :research_policy, view: :content, items: { view: :name }
  end

  def report_type_property
    field_nest :report_type, view: :content, items: { view: :name }
  end
end
