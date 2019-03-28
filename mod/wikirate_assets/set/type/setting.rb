format :json do
  def items_for_export
    Card.search left: { type: Card::SetID },
                right: card.id,
                limit: 0
  end
end
