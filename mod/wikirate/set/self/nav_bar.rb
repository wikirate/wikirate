include_set Abstract::CodeContent

basket[:cache_seed_names] << %i[cardtype featured]

format :html do
  view :core, template: :haml, cache: :deep
  view :slider, cache: :deep do
    Cache.populate_fields %i[cardtype featured].card.item_names, :image
    haml :slider
  end
end
