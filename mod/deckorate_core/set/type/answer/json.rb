format :json do
  def atom
    lookup = card.answer
    super.tap do |atom|
      atom.delete :content
      atom[:metric] = lookup.metric_name
      %i[company year value source comments].each do |key|
        atom[key] = lookup.send key
      end
      atom[:answer_url] = path mark: card.name.left, format: :json
    end
  end

  def molecule
    super.merge sources: field_nest(:source, view: :items),
                checked_by: field_nest(:checked_by, view: :items)
  end

  def item_cards
    return [] unless card.metric_card.relation?

    card.fetch(:relationship).format(:json).item_cards
  end

  private

  def atom_content?
    false
  end
end
