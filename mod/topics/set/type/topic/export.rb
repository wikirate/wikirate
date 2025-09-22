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
      "@context": context,
      "@id": resource_iri,
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
    return unless (category = card.category_card)

    path mark: category.first_name
  end

  def get_children
    card.subtopic_card.item_names.map { |name| path(mark: name, format: nil) }
  end
end

