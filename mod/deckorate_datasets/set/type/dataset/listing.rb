
format :html do
  bar_cols 7, 5

  view :bar_left do
    voo.size = :medium
    # filterable({ dataset: card.name, status: :all }, class: "w-100") do
    render_thumbnail
    # end
  end

  # view :bar_middle do
  #   field_nest :topic
  # end

  view :bar_right do
    [count_badges(:metric, :company), render_bookmark]
  end

  view :bar_bottom do
    [render_details_tab_left, render_details_tab_right]
  end

  view :box_middle do
    field_nest :image, view: :core, size: :medium
  end

  view :box_bottom do
    count_badges :metric, :company
  end

  def thumbnail_subtitle
    field_nest :year, view: :one_line_content, items: { view: :name }, unknown: :blank
  end

  def data_subset_detail
    labeled_field :parent, :link, title: "Data Subset of" unless card.parent.blank?
  end
end
