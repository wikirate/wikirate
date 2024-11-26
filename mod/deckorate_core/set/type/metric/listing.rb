format :html do
  view :bar_left do
    render :thumbnail
  end

  view :bar_right do
    [count_badges(:company, :answer, :reference), render_bookmark]
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
    count_badges :answer, :company
  end

  # thumbnails

  before :thumbnail do
    class_up "thumbnail", "metric-thumbnail"
  end

  def thumbnail
    haml :thumbnail
  end

  view :thumbnail_image do
    nest card.designer_image_card, view: thumbnail_image_view,
                                   size: thumbnail_image_size,
                                   title: "Designed by #{card.metric_designer}"
  end

  def thumbnail_subtitle
    nest card.metric_designer_card, view: :thumbnail_minimal, size: :icon
  end

  def metric_type_details
    card.metric_type_name
  end

  def goto_autocomplete_icon
    render_thumbnail_image
  end

  def autocomplete_name
    card.metric_title
  end
end
