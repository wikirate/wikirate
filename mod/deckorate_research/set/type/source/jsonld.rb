format :jsonld do

    def molecule
        source_jsonld()
    end

  private

    def source_jsonld  
        {
            "@context" => "#{request.base_url}/context/#{card.type}.jsonld",
            "@id"      => path(mark: card.name, format: nil),
            "@type"    => card.type,
            "name"     => card.name,
            "file" => card.file,
            "report_type" => get_report_type, 
            "company" => get_company,
            "year" => get_year       

        }.compact
    end

    def get_report_type
        card.report_type&.split("\n").presence
    end

    def get_year
        card.year&.split("\n").presence
    end

    def get_company
        companies = card.company&.split("\n") || nil
        companies&.any? ? companies.map { |company| path(mark: company, format: nil) } : nil
    end

end
