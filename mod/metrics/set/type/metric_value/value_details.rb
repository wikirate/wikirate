include_set Abstract::WikirateTable
include_set Abstract::ResearchedValueDetails

format :html do
  # We can't distinguish with sets between metric answers of metrics
  # of different metric types so we have different view for every type here.
  def value_details
    _render! "#{card.metric_type}_value_details"
  end

  # don't cache; view depends on formula card
  view :formula_value_details, cache: :never do
    wrap_value_details do
      wrap_with :div do
        [
          answer_details_table,
          wrap_with(:h5, "Formula"),
          "= #{formula}"
        ]
      end
    end
  end

  view :score_value_details, cache: :never do
    wrap_value_details do
      answer_details_table
    end
  end

  view :wikirating_value_details, cache: :never do
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

  def answer_details_table
    AnswerDetailsTable.new(self).render
  end

  def formula
    calculator = Formula::Calculator.new(card.metric_card.formula_card)
    calculator.formula_for card.company, card.year.to_i do |input|
      input = input.join ", " if input.is_a?(Array)
      "<span class='metric-value'>#{input}</span>"
    end
  end

  def company_year
    "#{card.company}+#{card.year}"
  end

  view :value_details_toggle do
    css_class = "fa fa-caret-right fa-lg margin-left-10 btn btn-outline-secondary btn-sm"
    wrap_with :i, "", class: css_class,
                      data: { toggle: "collapse-next",
                              parent: ".value",
                              collapse: ".metric-value-details" }
  end
end
