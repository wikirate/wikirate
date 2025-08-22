format :html do
  def standard_title
    voo.title ||= card.metric_title
    add_name_context card.name
    super
  end

  def header_text
    render_question
  end

  def header_list_items
    super.merge Designer: link_to_card(card.metric_designer),
                "Metric Type": card.metric_type
  end

  def image_card
    @image_card ||= card.metric_designer_card&.fetch :image, new: {}
  end

  def social_description
    card.question
  end

  # default tab list (several metric types override)
  def tab_list
    %i[details answer source dataset calculation]
  end

  def tab_options
    super.merge answer: { label: "Companies", count: card.company_card.cached_count }
  end

  # view :topic_tab do
  #   field_nest :topic
  # end

  view :answer_tab do
    field_nest :answer, view: :filtered_content
  end

  view :source_tab do
    field_nest :source, view: :filtered_content
  end

  view :dataset_tab do
    field_nest :dataset, view: :filtered_content
  end

  view :details_tab_left, template: :haml

  view :details_tab_right do
    render_metric_properties
  end

  view :title_and_question, template: :haml

  view :question do
    field_nest :question, view: :content, unknown: :blank
  end
end
