format :html do
  view :bar_left do
    render :thumbnail
  end

  view :bar_right do
    [count_badges(:wikirate_company, :metric_answer), render_bookmark]
  end

  view :bar_middle do
    result_middle { count_badges :source, :dataset }
  end

  view :bar_bottom do
    render_details_tab
  end

  view :box_top, template: :haml

  view :box_middle do
    render :question
  end

  view :box_bottom do
    count_badges :metric_answer, :wikirate_company
  end

  # thumbnails

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
    # FIXME: handle options from json
    # %i[year company unknown not_researched].map do |key|
    #   next unless (value = voo.send key)
    #   "#{key}: #{value}"
    # end.compact
  end
end
