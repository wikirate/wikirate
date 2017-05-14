format :html do
  # show codename in the title
  view :pointer_items, tags: :unknown_ok do |args|
    card.item_cards.map do |item_card|
      nest_item item_card, title: title do |rendered, view|
        wrap_item rendered, view
      end
    end.join args[:joint] || " "
  end
end
