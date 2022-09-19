def record_answers_card
  record_card.metric_answer_card
end

format :html do
  def tab_list
    list = %i[basics flag record calculations]
    list << :inputs if card.calculated?
    list.insert 1, :relationship_answer if card.relationship?
    list
  end

  def tab_options
    {
      record: { count: card.record_answers_card.count, label: "Years" },
      calculations: { count: card.depender_answers.count },
      inputs: { count: card.dependee_answers.count },
      relationship_answer: { count: relationship_count, label: "Relationships" }
    }
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

  view :relationship_answer_tab do
    field_nest :relationship_answer, view: :filtered_content
  end

  def relationship_count
    return 0 unless card.relationship?

    card.fetch(:relationship_answer).format.relationships.count
  end

  def read_field_configs
    [[metric_card.question_card.name, { title: "Question" }]] +
      if card.researched? && !card.relationship?
        edit_field_configs
      else
        advanced_read_field_configs
      end
  end

  def advanced_read_field_configs
    replacing_source_field edit_field_configs do
      card.relationship? ? nil : calculated_read_field_config
    end
  end

  def calculated_read_field_config
    title = calculation_overridden? ? "Overridden Answer" : "Formula"
    [card.name, title: title]
  end

  def replacing_source_field conf
    ([conf[0], yield] + conf[2..-1]).compact
  end

  def header_list_items
    super.merge(
      "Company": link_to_card(card.company_card),
      "Year": card.year
    )
  end

  # remove link to Answer Dashboard for now
  def breadcrumb_items
    super.tap { |i| i.slice! 1 }
  end
end
