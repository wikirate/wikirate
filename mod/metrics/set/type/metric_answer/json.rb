format :json do
  def atom
    super.tap do |atom|
      %i[metric company year].each do |key|
        atom[key] = card.send key
      end
      atom[:value] = card.value # nest card.value_card, view: :core
      atom[:record_url] = path mark: card.name.left, format: :json
      atom.delete(:content)
    end
  end

  def molecule
    super().merge sources: field_nest(:source, view: :items),
                  checked_by: field_nest(:checked_by)
  end

  def item_cards
    return [] unless card.metric_card.relationship?

    card.fetch(:relationship_search).relationship_answers
  end
end
