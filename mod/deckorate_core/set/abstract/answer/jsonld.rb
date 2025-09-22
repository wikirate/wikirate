format :jsonld do
  def get_value(metric)
    metric.value_type == "Multi-Category" ? card.value&.split(", ") : card.value
  end

  def get_sources
    sources = card.source_card&.item_names
    return unless sources.present?
    sources.map { |name| path(mark: name, format: nil) }
  end

  def get_unit metric
    if metric.metric_type == "Relation" || metric.metric_type == "Inverse Relation"
      return "related companies"
    end
    metric.unit.presence
  end
end
