include_set Abstract::Thumbnail

format :html do
  def default_thumbnail_args _args
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
    wrap_with(:div, thumbnail_title_text, class: "ellipsis")
  end

  def thumbnail_title_link
    title = thumbnail_title_text
    opts = { title: title, class: "ellipsis" }
    if voo.closest_live_option(:project)
      opts[:path] = { filter: { project: voo.closest_live_option(:project) } }
    end
    link_to_card card, title, opts
  end

  def thumbnail_title_text
    nest card.metric_title_card, view: :name
  end

  view :thumbnail_subtitle do |args|
    wrap_with :div do
      <<-HTML
      <small class="text-muted">
        #{args[:text]}
        #{args[:author]}
      </small>
      HTML
    end
  end

  def default_thumbnail_subtitle_args args
    args[:text] ||= [card.value_type, "designed by"].compact.join " | "
    args[:author] ||= link_to_card card.metric_designer
  end

  # not cacheable because formula arguments like "year=-1"
  # produce invalid stubs
  view :formula_thumbnail, cache: :never do
    "</span>#{_render_thumbnail}<span>"
  end

  view :fixed_value do
    nest [card, voo.closest_live_option(:params)], view: :value_link
  end

  view :score_thumbnail do |_args|
    ""
  end
end
