format :jsonld do
  def license_url metric
    nest metric.license_card, view: :url
  end

  def context
    "#{request&.base_url}/context/#{card.type}.jsonld"
  end

  def get_unit metric
    if metric.metric_type.in? ["Relation", "Inverse Relation"]
      "related companies"
    else
      metric.unit.presence
    end
  end
end
