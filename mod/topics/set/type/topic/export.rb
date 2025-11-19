format :json do
  def atom
    super.merge(
      # bookmarkers: card.bookmarkers_card.cached_count,
      title: card.name.right,
      framework: card.name.left,
      family: card.topic_family_title,
      parent: get_parent,
      children: get_children,
      metrics: path(mark: card.metric_card.name),
      datasets: path(mark: card.dataset_card.name)
    ).compact_blank!
  end

  private

  def get_parent
    return unless (category = card.category_card)

    category.first_name.presence || card.name.left
  end

  def get_children
    card.subtopic_card.item_names
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

    category.first_name.present? ? path(mark: category.first_name) : path(mark: card.name.left)
  end

  def get_children
    card.subtopic_card.item_names.map { |name| path(mark: name, format: nil) }
  end
end

