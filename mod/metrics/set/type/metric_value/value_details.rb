include_set Abstract::WikirateTable
include_set Abstract::ResearchedValueDetails

format :html do
  def value_details
    _render! "#{card.metric_type}_value_details"
  end

  view :formula_value_details do
    wrap_value_details do
      wrap_with :div do
        [
          answer_details_table,
          wrap_with(:h5, "Formula"),
          formula
        ]
      end
    end
  end

  def formula
    calculator = Formula::Calculator.new(card.metric_card.formula_card)
    result = calculator.formula_for card.company, card.year.to_i do |input|
      input = input.join ", " if is_a?(Array)
      "<span class='metric-value'>#{input.to_s}</span>"
    end
    "= #{result}"
    # nest(card.metric_card.formula_card,
    #                view: :core, params: company_year,
    #                items: { view: :fixed_value })
  end

  def company_year
    "#{card.company}+#{card.year}"
  end

  view :wikirating_value_details do
    wrap_value_details do
      wrap_with :div do
        [
          answer_details_table,
          wrap_with(:div, class: "col-md-12") do
            wrap_with(:div, class: "pull-right") { "= #{colorify card.value}" }
          end
        ]
      end
    end
  end

  view :score_value_details do
    wrap_value_details do
      answer_details_table
    end
  end

  def answer_details_table
    AnswerDetailsTable.new(self).render
  end

  view :value_details_toggle do
    css_class = "fa fa-caret-right fa-lg margin-left-10 btn btn-outline-secondary btn-sm"
    wrap_with(:i, "", class: css_class,
                      data: { toggle: "collapse-next",
                              parent: ".value",
                              collapse: ".metric-value-details" })
  end
end
