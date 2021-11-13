format :html do
  view :breadcrumb, unknown: true, template: :haml

  view :basic_details do
    render_concise hide: :year_and_icon
  end

  view :comments do
    wrap_with :div, class: "comments-div" do
      field_nest :discussion, view: :titled, title: "Comments", show: "comment_box"
    end
  end

  # FIXME: Can do this with way less custom code
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

  def edit_modal_size
    :full
  end
end
