format :jsonld do

    def molecule
        source_jsonld()
    end

  private

    def source_jsonld
        {
            "@context" => context,
            "@id" => resource_iri,
            "@type" => card.type,
            "name" => card.name,
            "file" => card.file,
            "report_type" => card.report_type_card&.item_names.presence,
            "company" => get_company,
            "year" => card.year_card&.item_names.presence

        }.compact
    end

    def get_company
        companies = card.company_card&.item_names
        return unless companies.present?
        companies.map { |name| path(mark: name, format: nil) }
    end

end
