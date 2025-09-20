format :jsonld do

    def molecule
        answer_jsonld()
    end

  private

    def answer_jsonld
        metric = card.metric_card
        {
            "@context" => context,
            "@id"      => path(mark: card.name, format: nil),
            "@type"    => card.type,
            "name"     => card.name,
            "company" => path(mark: card.company),
            "metric" => path(mark: card.metric),
            "value" => get_value(metric),
            "unit" => get_unit(metric),
            "year" => card.year,
            "source" => get_sources,
            "license" => license_url(metric)
        }.compact
    end
end
