format :jsonld do
  def get_value metric
    metric.multi_categorical? ? card.value&.split(", ") : card.value
  end

  def get_sources
    card.source_card.item_names.map { |name| path(mark: name, format: nil) }.presence
  end

  def get_unit metric
    if metric.metric_type.in? ["Relation", "Inverse Relation"]
      "related companies"
    else
      metric.unit.presence
    end
  end
end
