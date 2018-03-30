format :json do
  def items_for_export
    return [] if card.content.empty? ||
                 card.name.include?("+*options") ||
                 card.name.include?("+*structure")
    card.item_names(limit: 5)
  end
end
