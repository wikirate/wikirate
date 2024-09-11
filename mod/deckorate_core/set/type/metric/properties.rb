format :html do
  # all metrics show these properties in their properties table
  def basic_table_properties
    # designer:       "Designed by",
    # metric_type:    "Metric Type",
    { topic: "Topics",
      unpublished:    "Unpublished" }.merge applicability_properties
  end

  # all metrics have these properties in their editor
  def basic_edit_properties
    { question:       "Question",
      topic: "Topics",
      about:          "About",
      methodology:    "Methodology",
      unpublished:    "Unpublished" }.merge applicability_properties
  end

  def value_type_properties
    { value_type:    "Value Type",
      unit:          "Unit",
      range:         "Range",
      value_options: "Options" }
  end

  def research_properties
    { research_policy: "Research Policy",
      report_type:     "Report Type",
      steward:         "Steward" }
  end

  def applicability_properties
    { year:          "Years",
      company_group: "Company Groups" }
  end

  view :metric_properties do
    wrap_with :div, class: "metric-properties labeled-fields" do
      table_properties.map do |field, label|
        if respond_to? "#{field}_property"
          send "#{field}_property", label
        else
          labeled_field field, :name, title: label, separator: ", ", unknown: :blank
        end
      end
    end
  end

  before :content_formgroups do
    voo.edit_structure ||= edit_properties.to_a.map do |field, title|
      [field, title: title]
    end
  end

  # for override
  def table_properties
    basic_table_properties
  end

  def edit_properties
    basic_edit_properties
  end

  # SHARED

  def designer_property title, size=nil
    wrap :div, class: "row designer-property" do
      labeled title, nest(card.metric_designer_card, view: :thumbnail, size: size)
    end
  end

  def topic_property title
    labeled_field :topic, :link, title: title
  end

  def unpublished_property title
    return unless card.steward?

    labeled_field :unpublished, nil, title: title, unknown: :blank
  end

  def value_options_property title
    # not comma separated.
    labeled_field :value_options, :name, title: title
  end
end
