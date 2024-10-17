include_set Abstract::CodeContent

basket[:cache_seed_names] << %i[cardtype featured]

format :html do
  view :core, template: :haml
  view :slider, template: :haml

  before :slider do
    Cache.populate_fields %i[cardtype featured].card.item_names, :image
  end
end
