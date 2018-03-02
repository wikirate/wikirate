include Set::Abstract::Calculation

card_accessor :variables, type_id: Card::SessionID

format :html do
  view :content_formgroup do
    voo.edit_structure += [
      [:hybrid, "Researchable"],
      [:value_type, "Value Type"],
      [:research_policy, "Research Policy"],
      [:report_type, "Report Type"]
    ]
    super()
  end

  def value_type
    "Number"
  end

  def value_type_code
    :number
  end

  def thumbnail_metric_info
    "Formula"
  end

  def properties
    props = super.merge(hybrid: "Researchable")
    card.hybrid? ? props.merge(research_properties) : props
  end

  def hybrid_property
    metric_property_nest :hybrid
  end
end
