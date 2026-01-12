format :json do
  def atom
    super.merge(
      title: card.name.right_name,
      framework: card.name.left_name,
      family: card.topic_family_title,
      parent: card.parent.name,
      children: card.subtopic_card.item_names,
      metrics: { 
        count: card.metric_card.cached_count,
        url: path(mark: card.metric_card.name),
      },
      datasets: {
        count: card.dataset_card.cached_count,
        url: path(mark: card.dataset_card.name),
      },
      bookmarkers: card.bookmarkers_card.cached_count,
    ).compact_blank!
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
      "inScheme": path(mark: card.left),
      "parent": path(mark: card.parent),
      "children": get_children
    }.compact
  end

  private

  def get_children
    card.subtopic_card.item_names.map { |name| path(mark: name, format: nil) }
  end
end

