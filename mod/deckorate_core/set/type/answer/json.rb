format :json do
  def atom
    lookup = card.answer
    super.tap do |atom|
      atom.delete :content
      atom[:metric] = lookup.metric_name
      %i[company year value].each do |key|
        atom[key] = lookup.send key
      end
      atom[:unit] = get_unit(lookup.metric)
      atom[:source] = lookup.source
      atom[:comments] = lookup.comments
      atom[:answer_url] = path mark: card.name.left, format: :json

      atom.delete_if { |_k, v| v.blank? }
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

  def get_unit metric
    if metric.metric_type.in? ["Relation", "Inverse Relation"]
      "related companies"
    else
      metric.unit.presence
    end
  end
end
