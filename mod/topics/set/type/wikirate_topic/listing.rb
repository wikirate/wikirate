format :html do
  view :bar_left do
    render_thumbnail
  end

  view :bar_middle do
    result_middle { count_badges :research_group, :dataset }
  end

  view :bar_right do
    [count_badge(:metric), render_bookmark]
  end

  view :bar_bottom do
    [render_bar_middle, render_details]
  end

  view :box_middle do
    field_nest :image, view: :core, size: :medium
  end

  view :box_bottom do
    count_badges :metric, :dataset
  end
end
