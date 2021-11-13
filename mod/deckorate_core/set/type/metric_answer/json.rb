format :json do
  def atom
    lookup = card.answer
    nucleus.tap do |atom|
      atom[:metric] = lookup.metric_name
      %i[company year value comments].each do |key|
        atom[key] = lookup.send key
      end
      atom[:record_url] = path mark: card.name.left, format: :json
    end
  end

  def molecule
    super().merge sources: field_nest(:source, view: :items),
                  checked_by: field_nest(:checked_by)
  end

  def item_cards
    return [] unless card.metric_card.relationship?

    card.fetch(:relationship_answer).format(:json).item_cards
  end
end
