format :json do
  view :export_items do |_args|
    wql = { left:  { type: Card::SetID },
            right: card.id,
            limit: 0 }
    Card.search(wql).compact.map do |rule|
      subformat(rule).render_export
    end.flatten
  end
end
