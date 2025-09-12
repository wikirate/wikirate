format :json do
  def atom
    super.merge(
      bookmarkers: card.bookmarkers_card.cached_count,
      metrics: card.metric_card.cached_count,
      datasets: card.dataset_card.cached_count
    )
  end
end

format :jsonld do
  def molecule
    {
      "@context": "#{request.base_url}/context/#{card.type}.jsonld",
      "@id": path(mark: card.name),
      "@type": card.type,
      "name": card.name.parents[1],
      "description": card.fetch("Overview")&.content,
      "inScheme": path(mark: card.name.left), 
      "parent": get_parent,
      "children": get_children
    }.compact
  end

  private

  def get_parent
    category = card.fetch(:category)
    return nil unless category
    path mark: category&.item_cards[0].name if category
  end

  def get_children
    subtopics = card.fetch("subtopics")
    
    return [] unless subtopics

    subtopics.item_cards.map do |c|
      path mark: c.name
    end
  end
end
