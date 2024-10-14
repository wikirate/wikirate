include_set Abstract::CodeContent

format :html do
  view :core, template: :haml
  view :slider, template: :haml

  before :slider do
    Cache.populate_fields %i[cardtype featured].card.item_names, :image
  end
end
