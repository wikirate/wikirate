include_set Abstract::Thumbnail

format :html do
  before :thumbnail do
    class_up "thumbnail", "metric-thumbnail"
  end

  def thumbnail_image
    nest card.designer_image_card, view: thumbnail_image_view,
                                   size: :small,
                                   title: "Designed by #{card.metric_designer}"
  end

  # not hacky??  inline-block doesn't achieve this?
  view :formula_thumbnail do
    "</span>#{_render_thumbnail}<span>"
  end

  view :score_thumbnail do
    ""
  end

  def thumbnail_subtitle
    card.metric_type
  end
end
