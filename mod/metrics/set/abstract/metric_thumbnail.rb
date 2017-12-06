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
    return thumbnail_title_text unless voo.show?(:thumbnail_link)
    opts = { title: card.metric_title_card.name }
    if voo.closest_live_option(:project)
      opts[:path] = { filter: { project: voo.closest_live_option(:project) } }
    end
    link_to_card card, thumbnail_title_text, opts
  end

  def thumbnail_title_text
    wrap_with(:div, nest(card.metric_title_card, view: :name), class: "ellipsis")
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

  view :formula_thumbnail do
    "</span>#{_render_thumbnail}<span>"
  end

  view :fixed_value do
    nest [card, voo.closest_live_option(:params)], view: :value_link
  end

  view :score_thumbnail do |_args|
    ""
  end
end

