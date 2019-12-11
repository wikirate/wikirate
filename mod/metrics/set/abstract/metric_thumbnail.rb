include_set Abstract::Thumbnail

format :html do
  before :thumbnail do
    class_up "thumbnail", "metric-thumbnail"
  end

  view :thumbnail_image do
    nest card.designer_image_card, view: thumbnail_image_view,
                                   size: thumbnail_image_size,
                                   title: "Designed by #{card.metric_designer}"
  end

  # not hacky??  inline-block doesn't achieve this?
  view :formula_thumbnail do
    "</span>#{_render_thumbnail}<span>"
  end

  def thumbnail_subtitle
    [fixed_thumbnail_subtitle, formula_options].flatten.compact.join(" | ")
  end

  def fixed_thumbnail_subtitle
    card.metric_type
  end

  def formula_options
    %i[year company unknown not_researched].map do |key|
      next unless (value = voo.send key)
      "#{key}: #{value}"
    end.compact
  end
end
