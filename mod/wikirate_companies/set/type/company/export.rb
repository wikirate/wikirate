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
    CompanyIdentifier.names.map do |field_name|
      field_nest field_name, view: :content
    end
  end

  # DEPRECATED.  +answer csv replaces following:
  view :titled do
    field_nest :answer, view: :titled
  end
end
