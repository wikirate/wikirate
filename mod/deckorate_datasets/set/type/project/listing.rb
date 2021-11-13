format :html do
  info_bar_cols 6, 4, 2

  view :bar_left do
    voo.size = :medium
    render_thumbnail
  end

  view :bar_right do
    [nest(card.dataset_card, view: :default_research_progress_bar),
     field_nest(:wikirate_status, wrap: :em, items: { view: :name }, unknown: :blank)]
  end

  view :bar_bottom do
    render_data
  end

  def thumbnail_subtitle
    field_nest :organizer, view: :credit, unknown: :blank
  end
end
