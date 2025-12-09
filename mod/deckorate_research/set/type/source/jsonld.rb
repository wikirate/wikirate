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
      "file" => field_nest(:file, view: :content),
      "report_type" => card.report_type_card&.item_names.presence,
      "company" => get_company,
      "year" => card.year_card&.item_names.presence

    }.compact
  end

  def get_company
    card.company_card&.item_names.map { |name| path(mark: name, format: nil) }.presence
  end
end
