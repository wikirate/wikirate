include_set Abstract::Thumbnail

format :html do
  def thumbnail_image
    _render_image_link
  end

  def thumbnail_text
    _render_name_link
  end
end
