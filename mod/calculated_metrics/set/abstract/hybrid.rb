def hybrid?
  hybrid_card.checked?
end

format :html do
  def researchable_properties
    { hybrid: "Researchable" }.merge(research_properties)
  end

  def edit_properties
    super.merge(value_type_properties).merge researchable_properties
  end

  def table_properties
    super.merge(value_type_properties).merge researchable_properties
  end

  def hybrid_property
    metric_property_nest :hybrid
  end
end
