format :jsonld do

    def molecule
        answer_jsonld()
    end

  private

    def answer_jsonld  
        metric = card.metric_card
        {
            "@context" => "#{request.base_url}/context/#{card.type}.jsonld",
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

    def get_unit metric
        if metric.metric_type == "Relation" || metric.metric_type == "Inverse Relation"
            return "related companies"
        end
        metric.unit == "" ? nil : metric.unit
    end

end
