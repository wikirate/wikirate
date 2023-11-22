# TODO: move this to card mods
# (note: it won't work in wikirate_shared, because it needs to be available to deckorate
# mods)
format :html do
  view :breadcrumbs do
    breadcrumb breadcrumb_items
  end

  def breadcrumb_items
    type = card.type_card
    breadcrumb_card = Card[card.name]

    breadcrumb_array = [
      link_to("Home", href: "/"),
      link_to_card(type, type.name.vary(:plural)),
      render_name
    ]

    insert_parent_link(breadcrumb_array, breadcrumb_card) if should_insert_parent_link?(breadcrumb_card)

    breadcrumb_array
  end

  private

  def should_insert_parent_link? breadcrumb_card
    breadcrumb_card.parent != "" && card == breadcrumb_card
  end

  def insert_parent_link breadcrumb_array, breadcrumb_card
    breadcrumb_array.insert(-2, link_to_card(Card["#{breadcrumb_card.name}+Parent"].content))
  end
end
