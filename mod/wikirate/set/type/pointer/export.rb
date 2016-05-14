
format :json do
  view :export_items do |args|
    card.item_cards.map do |i_card|
      subformat(i_card).render_export(args)
    end.flatten.reject { |c| (c.nil? || c.empty?) }
  end
end
