def hybrid?
  hybrid_card.checked?
end

format :html do
  view :content_formgroup do
    # coffeescript hides the bottom three if _hybrid_ is not selected
    voo.edit_structure += [
      [:hybrid, "Researchable"],
      [:value_type, "Value Type"],
      [:research_policy, "Research Policy"],
      [:report_type, "Report Type"]
    ]
    super()
  end

  def properties
      props = super.merge(hybrid: "Researchable")
      card.hybrid? ? props.merge(research_properties) : props
  end

  def hybrid_property
    metric_property_nest :hybrid
  end
end
