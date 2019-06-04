include_set Abstract::TwoColumnLayout
include_set Abstract::BsBadge

format :html do
  def standard_title
    voo.title = card.metric_title
    add_name_context card.name
    super
  end

  def header_body size=:medium
    class_up "media-heading", "metric-color"
    @image_card = card.metric_designer_card.fetch trait: :image
    text_with_image title: render_vote_and_title,
                    text: render_question,
                    # alt: "Designed by: #{card.metric_designer}",
                    size: size
  end

  view :data, cache: :never do
    field_nest :metric_answer
  end

  view :vote_and_title do
    wrap_with :div, class: "d-flex" do
      [render_vote, render_title_link]
    end
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
    wrap_with :div, class: "icon-and-question d-flex" do
      [fa_icon(:question), field_nest(:question, view: :content)]
    end
  end
end
