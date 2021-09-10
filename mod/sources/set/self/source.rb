include_set Abstract::SourceFilter

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

  def each_url_source urls
    urls.each do |url|
      yield url, find_or_add_source_card(url) if url? url
    end
  end

  def find_or_add_source_card url
    found = search_by_url url
    return found.first if found.present?

    Card.create! type: SourceID, "+:wikirate_link": url, skip: :requirements
  end
end

format :html do
  view :titled_content, template: :haml
end
