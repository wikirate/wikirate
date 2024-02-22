include_set Abstract::Thumbnail

format :html do
  def thumbnail_subtitle
    field_nest :headquarters, view: :content, unknown: :blank, items: { view: :name }
  end

  # TODO: explain?
  view :unknown do
    _render_link
  end

  view :bar_left do
    render_thumbnail
  end

  view :bar_right do
    [count_badges(:metric_answer, :metric), render_bookmark]
  end

  view :bar_middle do
    result_middle { count_badges :source, :dataset }
  end

  view :bar_bottom do
    output [render_bar_middle, render_details_tab]
  end

  view :box_middle do
    field_nest :image, view: :core, size: :medium
  end

  view :box_bottom do
    count_badges :metric_answer, :metric
  end

  mini_bar_cols 7, 5
end
