format :jsonld do

    def molecule
        answer_jsonld()
    end

  private

    def answer_jsonld  
        metric = card.metric_card
        print ("Metric Cars: #{metric}")
        {
            "@context" => "#{request.base_url}/context/#{card.type}.jsonld",
            "@id"      => path(mark: card.name, format: nil),
            "@type"    => card.type,
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

    def license_url metric
        dir = metric.license.gsub(/(CC|4.0)/, "").strip.downcase
        "https://creativecommons.org/licenses/#{dir}/4.0/"
    end

    def get_value(metric)
        metric.value_type == "Multi-Category" ? card.value&.split(", ") : card.value
    end

    def get_sources
        sources = card.source&.split("\n") || []
        sources&.any? ? sources.map { |source| path(mark: source, format: nil) } : nil
    end

end
