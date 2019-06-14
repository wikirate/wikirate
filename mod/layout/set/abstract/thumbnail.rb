format :html do
  view :thumbnail do
    voo.show :thumbnail_link
    thumbnail
  end

  view :thumbnail_minimal do
    voo.hide! :thumbnail_subtitle
    voo.hide! :thumbnail_link
    thumbnail
  end

  view :thumbnail_no_link do
    voo.hide :thumbnail_link
    thumbnail
  end

  view :thumbnail_image do
    field_nest :image, view: thumbnail_image_view,
                       size: (voo.size.present? ? voo.size : :small)
  end

  view :thumbnail_subtitle do
    wrap_with :div, class: "thumbnail-subtitle" do
      thumbnail_subtitle
    end
  end

  def thumbnail
    haml :thumbnail
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
