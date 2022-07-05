format :html do
  basket[:head_views] << :wikirate_fonts

  # TODO: optimize: this should only be rendered once.
  view :wikirate_fonts, unknown: true, template: :haml
end
