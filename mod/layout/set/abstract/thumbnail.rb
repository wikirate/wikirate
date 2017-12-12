format :html do
  view :thumbnail_plain, cache: :never do |args|
    wrap_with :div, thumbnail_content(args)
  end

  view :thumbnail_minimal, cache: :never do |args|
    voo.hide! :thumbnail_subtitle
    voo.hide! :thumbnail_link
    _render_thumbnail_plain args
  end

  view :thumbnail, cache: :never do |args|
    voo.show :thumbnail_link
    wrap_with :div, thumbnail_content(args), class: "thumbnail"
  end

  view :thumbnail_no_link, cache: :never do |args|
    voo.hide :thumbnail_link
    wrap_with :div, thumbnail_content(args)
  end

  def thumbnail_content args
    output [
      thumbnail_image_wrap,
      thumbnail_text_wrap(args)
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

  def thumbnail_text_wrap args
    wrap_with :div, class: "thumbnail-text" do
      [
        thumbnail_title,
        _render_thumbnail_subtitle(args)
      ]
    end
  end

  def thumbnail_image
    image = field_nest(:image, view: :core, size: :small)
    return image unless voo.show?(:thumbnail_link)
    link_to_card card, image
  end

  def thumbnail_title
    title = _render_name
    wrap_with :div, class: "ellipsis", title: title do
      voo.show?(:thumbnail_link) ? _render_link : _render_name
    end
  end

  view :thumbnail_subtitle, cache: :never do |args|
    wrap_with :div do
      <<-HTML
      <small class="text-muted">
        #{args[:text]}
        #{args[:author]}
      </small>
      HTML
    end
  end
end
