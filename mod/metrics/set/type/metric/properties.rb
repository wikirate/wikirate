
format :html do
  # all metrics show these properties in their properties table
  def basic_table_properties
    { designer:       "Designed By",
      wikirate_topic: "Topics",
      metric_type:    "Metric Type" }
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
    wrap_with :div, class: "metric-properties" do
      table_properties.map do |field, label|
        if respond_to? "#{field}_property"
          send "#{field}_property", label
        else
          metric_property_nest field, label
        end
      end
    end
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

  # SHARED

  def designer_property title
    wrap :div, class: "row designer-property" do
      labeled title, nest(card.metric_designer_card, view: :thumbnail)
    end
  end

  def wikirate_topic_property title
    metric_property_nest :wikirate_topic, title, item_view: :link
  end

  private

  def metric_property_nest field, title, item_view: :name
    field_nest field, view: :labeled, title: title, items: { view: item_view }
  end
end
