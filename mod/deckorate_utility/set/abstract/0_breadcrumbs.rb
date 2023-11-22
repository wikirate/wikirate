# TODO: move this to card mods
# (note: it won't work in wikirate_shared, because it needs to be available to deckorate
# mods)
format :html do
  view :breadcrumbs do
    breadcrumb breadcrumb_items
  end

  def breadcrumb_items
    type = card.type_card
    breadcrumb_array = [
      link_to("Home", href: "/"),
      link_to_card(type, type.name.vary(:plural)),
      render_name
    ]

    breadcrumb_item = Card[card.name]

    breadcrumb_array.insert(-2, link_to_card(Card["#{breadcrumb_item.name}+Parent"].content)) \
      if breadcrumb_item.parent != "" && card == breadcrumb_item

    breadcrumb_array
  end
end
