format :json do
  view :links do
    []
  end

  view :items do
    []
  end

  view :odyssey do
    options = { filter: { year: "latest", metric_type: "Researched" }, limit: 5 }
    data = format_odyssey_record(odyssey_lookup_search(:record, options))
    {
      name: card.name,
      os_id: card.oar_id,
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
      h[:records_url] = path mark: card.name.field(:record), format: :json
    end
  end

  private

  def add_fields_to_hash hash, view=:atom
    card.simple_field_names.each do |fld|
      key = fld.underscore.parameterize.underscore
      # first underscore addresses camelcase. parameterize addresses spaces
      hash[key] = field_nest fld, view: view
    end
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

  def format_odyssey_relationships records
    items = []
    records.each do |record|
      items.append metric: record.metric.name,
                   subject_company: odyssey_url(record.subject_company_id),
                   object_company: odyssey_url(record.object_company_id),
                   value: record.value,
                   year: record.year,
                   source: record.source.card&.name
    end
    items
  end

  def odyssey_url company_id
    base_url = "#{Env.protocol}#{Env.host}"
    card_name = company_id.card.name.url_key
    "#{base_url}/#{card_name}.json?view=odyssey"
  end

  def format_odyssey_record records
    items = []
    records.each do |record|
      items.append metric: record.metric.name,
                   value: record.value,
                   year: record.year,
                   source: record.source.card&.name
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
    CompanyIdentifier.names.map do |field_name|
      field_nest field_name, view: :content
    end
  end

  # DEPRECATED.  +record csv replaces following:
  view :titled do
    field_nest :record, view: :titled
  end
end
