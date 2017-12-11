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
          _render_formula_table,
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
          _render_wikirating_table,
          wrap_with(:div, class: "col-md-12") do
            wrap_with(:div, class: "pull-right") { "= #{colorify card.value}" }
          end
        ]
      end
    end
  end

  view :score_value_details do
    wrap_value_details do
      metric_thumbnail = nest(base_metric_card(card), view: :thumbnail)
      value =
        wrap_with(:span, base_metric_value(card).value, class: "metric-value")
      table([[metric_thumbnail, value]], header: ["Original Metric", "Value"])
    end
  end

  view :formula_table do
    table_content =
      card.metric_card.formula_card.input_cards.map do |item_card|
        next if item_card.type_id == YearlyVariableID
        metric_row(item_card)
      end.compact

    table(table_content, header: ["Metric", "Raw Value", "Score"])
  end

  view :wikirating_table do
    table_content =
      card.metric_card.formula_card.translation_table.map do |card_name, weight|
        card = Card.fetch(card_name)
        metric_row(card, weight)
      end
    columns = ["Metric", "Raw Value", "Score", "Weight", "Points"]
    table(table_content, header: columns)
  end

  def metric_row input_card, weight=""
    wql = input_card.metric_value_query
    wql[:left][:right] = card.company_name
    wql[:right] = card.year
    return unless  (value_card = Card.search(wql).first)
    metric_row_values(input_card, value_card, weight)
  end

  def metric_row_values input_card, value_card, weight
    score_value = ""
    if value_card.metric_type == :score
      score_value = value_card.value
      raw_value = base_metric_value(value_card).value
    else
      raw_value = value_card.value
    end
    raw_value = wrap_with(:span, raw_value, class: "metric-value")
    metric_row_content(input_card, weight, raw_value, score_value)
  end

  def metric_row_content input_card, weight, raw_value, score_value
    metric_thumbnail = nest(input_card, view: :thumbnail)
    content_array = [metric_thumbnail, raw_value, colorify(score_value)]
    if card.metric_type == :formula
      content_array
    else
      points = (score_value.to_f * (weight.to_f / 100)).round(1)
      content_array.push("x " + weight + "%", "= " + points.to_s)
    end
  end

  def base_metric_card score_card
    score_card.metric_card.left
  end

  def base_metric_value score_card
    metric = base_metric_card(score_card)
    with_company = metric.field(card.company_name)
    with_company.field(card.year)
  end

  view :value_details_toggle do
    css_class = "fa fa-caret-right fa-lg margin-left-10 btn btn-outline-secondary btn-sm"
    wrap_with(:i, "", class: css_class,
                      data: { toggle: "collapse-next",
                              parent: ".value",
                              collapse: ".metric-value-details" })
  end
end
