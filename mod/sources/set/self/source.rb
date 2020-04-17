
class << self
  def search term
    if url? term
      name = Card::Env::Location.cardname_from_url term
      name ? search_by_name(name) : search_by_url(term)
    else
      search_by_name term
    end
  end

  def url? term
    term.match?(/^http/)
  end

  def search_by_name term
    card = Card[term]
    card&.type_id == SourceID ? [card] : []
  end

  def search_by_url url
    Card.search type_id: SourceID, right_plus: [WikirateLinkID, { content: url }]
  end
end

format :html do
  view :core, template: :haml
end
