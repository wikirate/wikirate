format :jsonld do

  def molecule
    answer_jsonld()
  end

  private

  def answer_jsonld
    metric = card.metric_card
    print ("Metric Cars: #{metric}")
    {
      "@context" => context,
      "@id" => resource_iri,
      "@type" => card.type,
      "name" => card.name,
      "metric" => path(mark: card.metric),
      "subject_company" => path(mark: card.company),
      "object_company" => path(mark: card.related_company),
      "predicate" => metric.metric_title,
      "value" => get_value(metric),
      "unit" => metric.unit.presence,
      "year" => card.year,
      "source" => get_sources,
      "license" => license_url(metric)
    }.compact
  end
end
