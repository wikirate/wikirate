include_set Abstract::Thumbnail

format :html do
  before :thumbnail do
    class_up "thumbnail", "metric-thumbnail"
  end

  def thumbnail_image
    if voo.show? :thumbnail_link
      designer_image_link
    else
      designer_image
    end
  end

  def thumbnail_title
    voo.show?(:thumbnail_link) ? thumbnail_title_link : thumbnail_title_without_link
  end

  def thumbnail_title_without_link
    wrap_with :div, thumbnail_title_text
  end

  def thumbnail_title_link
    link_to_card card, thumbnail_title_text, title: card.name
  end

  def thumbnail_title_text
    nest card.metric_title_card, view: :name
  end

  view :formula_thumbnail do
    "</span>#{_render_thumbnail}<span>"
  end

  # view :fixed_value do
  #   nest [card, voo.inherit(:params)], view: :value_link
  # end

  view :score_thumbnail do
    ""
  end

  def thumbnail_subtitle_text
    card.metric_type
  end
end
