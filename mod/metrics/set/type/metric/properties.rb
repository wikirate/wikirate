
format :html do
  # all metrics show these properties in their properties table
  def basic_table_properties
    { metric_type:    "Metric Type",
      designer:       "Designed By",
      wikirate_topic: "Topics" }
  end

  # all metrics have these properties in their editor
  def basic_edit_properties
    { question:       "Question",
      wikirate_topic: "Topic",
      about:          "About",
      methodology:    "Methodology" }
  end

  def value_type_properties
    { value_type:    "Value Type",
      unit:          "Unit",
      range:         "Range",
      value_options: "Options" }
  end

  def research_properties
    { research_policy: "Research Policy",
      report_type:     "Report Type" }
  end

  view :metric_properties do
    table table_property_rows, class: "metric-properties"
  end

  before :content_formgroup do
    voo.edit_structure = edit_properties.to_a
  end

  # for override
  def table_properties
    basic_table_properties
  end

  def edit_properties
    basic_edit_properties
  end

  def table_property_rows
    table_properties.each_with_object({}) do |(p_name, p_label), p_hash|
      next unless (row_value = send "#{p_name}_property")
      p_hash[p_label] = row_value
      p_hash
    end
  end

  # SHARED

  # the designer is derived from the name, which makes it an unusual property
  def designer_property
    nest card.metric_designer_card, view: :designer_slot, hide: :horizontal_menu
  end

  def wikirate_topic_property
    metric_property_nest :wikirate_topic, item_view: :link
  end

  def metric_type_property
    metric_property_nest :metric_type
  end

  # RESEARCHED

  def research_policy_property
    metric_property_nest :research_policy
  end

  def report_type_property
    metric_property_nest :report_type
  end

  def value_type_property
    metric_property_nest :value_type
  end

  # value type specific

  def unit_property
    metric_property_nest :unit
  end

  def range_property
    metric_property_nest :range
  end

  def value_options_property
    metric_property_nest :value_options
  end

  private

  def metric_property_nest field, item_view: :name
    field_nest field, view: :content, show: :menu, items: { view: item_view }
  end
end
