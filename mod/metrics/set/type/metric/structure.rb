format :html do
  def standard_title
    voo.title = card.metric_title
    add_name_context card.name
    super
  end

  def header_body
    class_up "media-heading", "metric-color"
    super
  end

  def header_text
    render_question
  end

  def image_card
    @image_card ||= card.metric_designer_card.fetch :image, new: {}
  end

  def social_description
    card.question
  end

  view :data do
    field_nest :metric_answer, view: :filtered_content
  end

  # TODO: fix homepage and get rid of this!
  view :title_and_question_compact do
    link = link_to_card card, card.metric_title, class: "inherit-anchor"
    wrap_with :div, class: "bg-white" do
      [wrap_with(:div, link, class: "metric-color font-weight-bold"),
       render_question]
    end
  end

  view :question do
    field_nest :question, view: :content
  end
end
