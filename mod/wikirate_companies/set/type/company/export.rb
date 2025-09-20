format :json do
  view :links do
    []
  end

  view :items do
    []
  end

  def atom
    super.tap do |h|
      h.delete :content
      add_fields_to_hash h, :core
    end
  end

  def molecule
    super.tap do |h|
      add_fields_to_hash(h)
      h[:answers_url] = path mark: card.name.field(:answer), format: :json
    end
  end

  private

  def add_fields_to_hash hash, view=:atom
    card.simple_field_cards # prepopulate
    card.simple_field_names.each do |fld|
      key = fld.underscore.parameterize.underscore
      hash[key] = field_val_from_cache fld, view
    end
  end

  def field_val_from_cache field, view
    return unless Card.cache.temp.exist? card.cardname.field_name(field).key

    field_nest field, view: view
  end

end

format :csv do
  view :row do
    super() + [card.headquarters, aliases] + identifiers
  end

  def aliases
    card.alias_card&.item_names&.join ";"
  end

  def identifiers
    map_identifier_cards do |card|
      nest card, view: :content if card
    end
  end

  def map_identifier_cards
    names = CompanyIdentifier.names
    id_cards = identifier_cards names
    names.map { |name| yield id_cards[name] }
  end

  def identifier_cards names
    Card.search(left: card.id, right_id: names.map(&:card_id).unshift(:in))
        .each_with_object({}) do |card, hash|
      hash[card.name.right_name] = card
    end
  end

  # DEPRECATED.  +answer csv replaces following:
  view :titled do
    field_nest :answer, view: :titled
  end
end

format :jsonld do
  view :molecule do
    company_jsonld(atom.symbolize_keys!)
  end

  private

  def company_jsonld(a)
    {
      "@context" => context,
      "@id" => path(mark: card.name, format: nil),
      "@type" => card.type,

      "name" => a[:name],
      "alias" => a[:alias],
      "logo" => a[:image],
      "country" => get_country,

      # identifiers (map 1:1 from atom)
      # TODO: fix here when we link url patterns with identifiers
      "lei" => a[:legal_entity_identifier],
      "isin" => a[:international_securities_identification_number],
      "open_corporates_id" => a[:open_corporates_id],
      "wikidata_id" => a[:wikidata_id],
      "australian_business_number" => a[:australian_business_number],
      "australian_company_number" => a[:australian_company_number],
      "os_id" => a[:open_supply_id],
      "uk_company_number" => a[:uk_company_number],
      "cik" => a[:sec_central_index_key],

      # outbound equivalences
      "same_as" => same_as_from_atom(a)
    }.compact
  end

  def get_country
    Card.fetch(card.headquarters)&.country
  end

  def same_as_from_atom(a)
    website = a[:website]
    wiki = a[:wikipedia]
    lei = a[:legal_entity_identifier]
    oc = a[:open_corporates_id]
    wd = a[:wikidata_id]

    links = []
    links << website if website.present?
    links << "https://en.wikipedia.org/wiki/#{wiki}" if wiki.present?
    links << "https://opencorporates.com/companies/#{Card.fetch(card.headquarters)&.oc_jurisdiction_key}/#{oc}" if oc.present?
    links << "https://search.gleif.org/#/record/#{lei}" if lei.present?
    links << "https://www.wikidata.org/wiki/#{wd}" if wd.present?
    links.empty? ? nil : links
  end
end
