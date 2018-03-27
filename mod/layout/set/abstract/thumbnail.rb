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

  def flex_css
    "d-flex align-items-center"
  end

  def thumbnail
    wrap_with :div, thumbnail_content, class: "thumbnail #{flex_css}",
                                       data: wrap_data(false)
  end

  view :thumbnail_no_link do
    voo.hide :thumbnail_link
    thumbnail
  end

  def thumbnail_content
    output [
      thumbnail_image_wrap,
      thumbnail_text_wrap
    ]
  end

  def thumbnail_image_wrap
    wrap_with :div, class: "image-box icon mt-1 align-self-start" do
      [
        wrap_with(:span, "", class: "img-helper"),
        thumbnail_image
      ]
    end
  end

  def thumbnail_text_wrap
    wrap_with :div, class: "thumbnail-text" do
      [
        thumbnail_title,
        _render_thumbnail_subtitle
      ]
    end
  end

  def thumbnail_image
    if voo.show?(:thumbnail_link)
      thumbnail_image_with_link
    else
      thumbnail_image_without_link
    end
  end

  def thumbnail_image_without_link
    field_nest :image, view: :core, size: :small
  end

  def thumbnail_image_with_link
    link_to_card card, thumbnail_image_without_link
  end

  def thumbnail_title
    title = _render_name
    wrap_with :div, title: title do
      voo.show?(:thumbnail_link) ? _render_link : _render_name
    end
  end

  view :thumbnail_subtitle do
    haml do
      <<-HAML.strip_heredoc
        %div
          %small.text-muted
            = thumbnail_subtitle_text
            = thumbnail_subtitle_author
      HAML
    end
  end

  def thumbnail_subtitle_text
    ""
  end

  def thumbnail_subtitle_author
    ""
  end
end
