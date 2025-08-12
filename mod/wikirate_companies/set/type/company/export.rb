format :json do
  view :links do
    []
  end

  view :items do
    []
  end

  view :odyssey do
    options = { filter: { year: "latest", metric_type: "Researched" }, limit: 5 }
    data = format_odyssey_answer(odyssey_lookup_search(:answer, options))
    {
      name: card.name,
      os_id: card.fetch(:oar_id)&.content,
      identifiers: {
        wikirate_id: card.id
      },
      relationships: format_odyssey_relationships(odyssey_relationships),
      data: data
    }
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

  def odyssey_lookup_search codename, options
    query_hash = card.fetch(codename).query_hash.merge(options[:filter])
    card.fetch(codename).query_class.new(
      query_hash, {},
      limit: options[:limit],
      offset: options[:offset]
    ).lookup_relation.all
  end

  def odyssey_relationships
    ::Relationship.where(
      "subject_company_id = #{card.id} OR object_company_id = #{card.id}"
    ).limit(10).all
  end

  def format_odyssey_relationships answers
    items = []
    answers.each do |answer|
      items.append metric: answer.metric.name,
                   subject_company: odyssey_url(answer.subject_company_id),
                   object_company: odyssey_url(answer.object_company_id),
                   value: answer.value,
                   year: answer.year,
                   source: answer.source.card&.name
    end
    items
  end

  def odyssey_url company_id
    base_url = "#{Env.protocol}#{Env.host}"
    card_name = company_id.card.name.url_key
    "#{base_url}/#{card_name}.json?view=odyssey"
  end

  def format_odyssey_answer answers
    items = []
    answers.each do |answer|
      items.append metric: answer.metric.name,
                   value: answer.value,
                   year: answer.year,
                   source: answer.source.card&.name
    end
    items
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
    company_jsonld(atom)
  end

  private
  # ---- Company ---------------------------------------------------------------

  def company_jsonld(a)
    {
      "@context" => "https://wikirate.org/context/Company.jsonld",
      "@id"      => path(mark: card.name, format: nil),
      "@type"    => "Company",

      # core identity
      "name"     => a[:name] || a["name"],
      "alias"    => a[:alias] || a["alias"],
      "logo"     => a[:image] || a["image"],
      "country"  => a[:headquarters] || a["headquarters"],

      # identifiers (map 1:1 from your atom)
      "lei"                         => a[:legal_entity_identifier] || a["legal_entity_identifier"],
      "isin"                        => a[:international_securities_identification_number] || a["international_securities_identification_number"],
      "open_corporates_id"          => a[:open_corporates_id] || a["open_corporates_id"],
      "wikidata_id"                 => a[:wikidata_id] || a["wikidata_id"],
      "australian_business_number"  => a[:australian_business_number] || a["australian_business_number"],
      "australian_company_number"   => a[:australian_company_number] || a["australian_company_number"],
      "os_id"                       => a[:open_supply_id] || a["open_supply_id"],
      "uk_company_number"           => a[:uk_company_number] || a["uk_company_number"],
      "cik"                         => a[:sec_central_index_key] || a["sec_central_index_key"],

      # outbound equivalences
      "same_as" => same_as_from_atom(a)
    }.compact
  end

  def same_as_from_atom(a)
    website = a[:website] || a["website"]
    wiki    = a[:wikipedia] || a["wikipedia"]
    lei    = a[:legal_entity_identifier] || a["legal_entity_identifier"]
    oc      = a[:open_corporates_id] || a["open_corporates_id"]
    wd      = a[:wikidata_id] || a["wikidata_id"]

    links = []
    links << website if website.present?
    links << "https://en.wikipedia.org/wiki/#{wiki}" if wiki.present?
    links << "https://opencorporates.com/companies/#{oc}" if oc.present?
    links << "https://search.gleif.org/#/record/#{lei}" if lei.present?
    links << "https://www.wikidata.org/wiki/#{wd}" if wd.present?
    links.empty? ? nil : links
  end
end
