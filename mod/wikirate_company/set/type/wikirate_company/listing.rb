include_set Abstract::Thumbnail

format :html do
  def thumbnail_subtitle
    field_nest :headquarters, view: :core, items: { view: :name }
  end

  # TODO: explain?
  view :missing do
    _render_link
  end

  view :bar_left do
    render_thumbnail
  end

  view :bar_right do
    count_badges :metric, :metric_answer
  end

  view :bar_middle do
    count_badges :wikirate_topic, :source, :project
  end

  view :bar_bottom do
    output [render_bar_middle, wikipedia_extract, open_corporates_extract]
  end

  view :box_middle do
    field_nest :image, view: :core, size: :medium
  end

  view :box_bottom do
    count_badges :metric, :wikirate_topic
  end

  bar_cols 7, 5
end
