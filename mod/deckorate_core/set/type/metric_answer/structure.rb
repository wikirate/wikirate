def record_answers_card
  record_card.metric_answer_card
end

format :html do
  def tab_list
    list = %i[details record calculations]
    list << (card.calculated? ? :inputs : :contributions)
    list.insert 1, :relationship_answer if card.relationship?
    list
  end

  def tab_options
    {
      contributions: { label: "Contributions" },
      record: { count: card.record_answers_card.count, label: "Years" },
      calculations: { count: card.depender_answers.count },
      # inputs: { count: card.dependee_answers.count },
      # NOTE: the inputs count is super slow on complicated answers, like
      # https://wikirate.org/Apparel_Research_Group+ESG_Disclosure_Rate+Adidas_AG+2020
      # The problem is that it has to traverse the answers via the calculators in
      # order to make sure it handles funky formulas correctly, and that takes a long
      # time when there are thousands of inputs.
      relationship_answer: { count: relationship_count, label: "Relationships" }
    }
  end

  view :header_right do
    if card.unpublished?
      wrap_with :div, class: "alert alert-warning" do
        "Unpublished"
      end
    end
  end

  view :details_tab, wrap: :slot, template: :haml

  view :contributions_tab do
    relative_history
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
    return "" unless card.relationship?

    field_nest :relationship_answer, view: :filtered_content
  end

  view :read_form, cache: :never do
    super()
  end

  def relationship_count
    return 0 unless card.relationship?

    card.fetch(:relationship_answer).format.relationships.count
  end

  def read_field_configs
    flag_field_configs + special_field_configs + [discussion_field_config]
  end

  def special_field_configs
    if card.relationship?
      []
    elsif card.researched?
      [source_field_config]
    else
      calculated_read_field_configs
    end
  end

  def flag_field_configs
    flag_card = card.flag_card
    return [] unless flag_card.count.positive?

    [[flag_card, title: "Flags", items:  { view: :accordion_bar }]]
  end

  def calculated_read_field_configs
    title = calculation_overridden? ? "Overridden Answer" : "Formula"
    [[card.name, title: title]]
  end

  def header_list_items
    super.merge(
      "Company": link_to_card(card.company_card),
      "Year": card.year,
      "Status": render_verification
    )
  end
end
