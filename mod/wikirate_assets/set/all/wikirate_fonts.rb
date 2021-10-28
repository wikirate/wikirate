format :html do
  def views_in_head
    super << :wikirate_fonts
  end

  # TODO: optimize: this should only be rendered once.
  view :wikirate_fonts, unknown: true, template: :haml
end
