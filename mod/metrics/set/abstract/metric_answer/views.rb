format :html do
  view :comments do
    disc_card = card.fetch trait: :discussion, new: {}
    subformat(disc_card)._render_titled title: "Comments", show: "commentbox",
                                        home_view: :titled
  end

  view :homepage_answer_example, template: :haml do
    @company_image = nest company_card.image_card, size: :small
    @company_link =
      link_to_card card.company_card, card.answer.company, class: "inherit-anchor"
    @metric_image = nest metric_designer_card.try(:image_card), size: :small
    @metric_question = nest card.answer.metric, view: :title_and_question_compact
  end

  def metric_designer_card
    Card.fetch metric_card.metric_designer
  end
end
