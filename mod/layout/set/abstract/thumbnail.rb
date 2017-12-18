format :html do
  view :thumbnail_plain do
    wrap_with :div, thumbnail_content
  end

  view :thumbnail_minimal do
    voo.hide! :thumbnail_subtitle
    voo.hide! :thumbnail_link
    _render_thumbnail_plain
  end

  view :thumbnail do
    thumbnail
  end

  def thumbnail
    voo.show :thumbnail_link
    wrap_with :div, thumbnail_content, class: "thumbnail"
  end

  view :thumbnail_no_link do
    voo.hide :thumbnail_link
    wrap_with :div, thumbnail_content
  end

  def thumbnail_content
    output [
      thumbnail_image_wrap,
      thumbnail_text_wrap
    ]
  end

  def thumbnail_image_wrap
    wrap_with :div, class: "pull-left image-box icon" do
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
    wrap_with :div, class: "ellipsis", title: title do
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
