format :html do
  view :bar_left do
    render_thumbnail_with_bookmark
  end

  view :bar_middle do
    count_badges :research_group, :project
  end

  view :bar_right do
    count_badge :metric
  end

  view :bar_bottom do
    [render_bar_middle, render_data]
  end

  view :box_middle do
    field_nest :image, view: :core, size: :medium
  end

  view :box_bottom do
    count_badges :metric, :project
  end
end
