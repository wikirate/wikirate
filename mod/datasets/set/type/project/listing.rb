format :html do
  info_bar_cols 6, 4, 2

  view :bar_left do
    voo.size = :medium
    render_thumbnail
  end

  # view :bar_middle do
  #   field_nest :wikirate_topic
  # end

  view :bar_right do
    field_nest :wikirate_status, items: { view: :name }
  end

  view :bar_bottom do
    render_data
  end

  def thumbnail_subtitle
    field_nest(:organizer, view: :credit)
  end

  def data_subset_detail
    return if card.parent.blank?
    labeled_field :parent, :link, title: "Data Subset of"
  end
end
