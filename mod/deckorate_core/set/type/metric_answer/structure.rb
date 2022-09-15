include_set Abstract::DeckorateTabbed

def record_answers_card
  record_card.metric_answer_card
end

format :html do
  def tab_list
    %i[basics flag record calculations].tap do |list|
      list << :inputs if card.calculated?
    end
  end

  def tab_options
    {
      record: { count: card.record_answers_card.count, label: "Years" },
      calculations: { count: card.depender_answers.count },
      inputs: { count: card.dependee_answers.count }
    }
  end

  def read_field_configs
    [[metric_card.question_card.name, { title: "Question" }]] +
      (card.researched? ? super : calculated_read_field_configs(super))
  end

  def calculated_read_field_configs conf
    title = calculation_overridden? ? "Overridden Answer" : "Formula"
    [conf[0], [card.name, { title: title }]] + conf[2..-1]
  end

  view :basics_tab do
    render_read_form
  end

  view :header_left do
    render_header_list
  end

  view :flag_tab do
    field_nest :flag, items: { view: :accordion_bar }
  end

  view :record_tab do
    nest record_card.metric_answer_card, view: :filtered_content
  end

  view :calculations_tab do
    card.depender_answers.map { |a| nest a, view: :bar }
  end

  view :inputs_tab do
    card.dependee_answers.map { |a| nest a, view: :bar }
  end

  def header_list_items
    metric = card.metric_card
    super.merge(
      "Metric Designer": link_to_card(metric.metric_designer),
      "Metric Title": link_to_card(metric, metric.metric_title),
      "Company": link_to_card(card.company_card),
      "Year": card.year
    )
  end

  def breadcrumb_items
    super.tap { |i| i.slice! 1 }
  end
end
