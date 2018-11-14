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
    @metric_image = nest metric_designer_card.image_card, size: :small
    @metric_question = nest card.answer.metric, view: :title_and_question_compact
  end

  view :sources do
    source_options = { view: :core, items: { view: :cited } }
    source_options[:items][:hide] = :cited_source_links if voo.hide? :cited_source_links
    output [
      citations_count,
      nest(source_card, source_options)
    ]
  end

  def metric_designer_card
    Card.fetch metric_card.metric_designer
  end

  def source_card
    card.fetch trait: :source
  end

  def citations_count_badge
    wrap_with :span, source_card&.item_names&.size, class: "badge badge-light border"
  end

  def citations_count
    wrap_with :h5 do
      ["Citations", citations_count_badge]
    end
  end

  view :sources_with_cited_button do
    with_nest_mode :normal do
      field_nest :source, view: :core, items: { view: :with_cited_button }
    end
  end
end
