format :html do
  view :sources do
    nest card.source_card, view: :titled, title: "Sources", items: { view: :bar }
  end

  def wikirate_source_from_url
    mdata = source_search_term.match(%r{//wikirate\.org/(.*)$})
    return unless mdata && (source_card = Card[mdata[1]])
    [source_card]
  end
end
