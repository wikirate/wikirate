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
    opts = { title: card.name, class: "ellipsis" }
    if voo.closest_live_option(:project)
      opts[:path] = { filter: { project: voo.closest_live_option(:project) } }
    end
    link_to_card card, thumbnail_title_text, opts
  end

  def thumbnail_title_text
    nest card.metric_title_card, view: :name
  end

  view :formula_thumbnail do
    "</span>#{thumbnail}<span>"
  end

  view :fixed_value do
    nest [card, voo.closest_live_option(:params)], view: :value_link
  end

  view :score_thumbnail do
    ""
  end

  def thumbnail_subtitle_text
    [thumbnail_metric_info, "designed by"].compact.join " | "
  end

  def thumbnail_metric_info
    card.value_type
  end

  def thumbnail_subtitle_author
    link_to_card card.metric_designer
  end
end
