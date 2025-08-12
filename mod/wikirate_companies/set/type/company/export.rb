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
