format :html do
  view :thumbnail_plain do
    wrap_with :div, thumbnail_content, class: flex_css
  end

  view :thumbnail_minimal do
    voo.hide! :thumbnail_subtitle
    voo.hide! :thumbnail_link
    _render_thumbnail_plain
  end

  view :thumbnail do
    voo.show :thumbnail_link
    thumbnail
  end

  view :thumbnail_no_link do
    voo.hide :thumbnail_link
    thumbnail
  end

  def flex_css
    "d-flex align-items-center"
  end

  def thumbnail
    haml :thumbnail
  end

  def thumbnail_image
    field_nest :image, view: thumbnail_image_view, size: :small
  end

  def thumbnail_image_view
    voo.show?(:thumbnail_link) ? :boxed_link : :boxed
  end

  def thumbnail_title
    voo.show :title_link if voo.show? :thumbnail_link
    render_title
  end

  # for override
  def thumbnail_subtitle
    ""
  end
end
