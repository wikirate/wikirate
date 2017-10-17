include_set Abstract::ValueToggle

format :html do
  view :closed_answer do
    if card.relationship?
      return output([value_field, _render_relationship_value_details])
    end
    class_up "vis", "pull-right"
    output [row, empty_details_slot]
  end

  # used for new_metric_value of a company
  # TODO merge with closed_answer view;
  view :closed_answer_without_chart do
    voo.hide! :chart
    output [row, empty_details_slot]
  end

  def value_field
    wrap_with :div, class: "value text-align-left" do
      [
        wrap_with(:span, currency, class: "metric-unit"),
        _render_value_link,
        wrap_with(:span, legend, class: "metric-unit"),
        _render_flags,
        _optional_render_chart
      ]
    end
  end

  view :plain_year do
    card.name.right
  end

  def legend
    return if currency.present?
    subformat(card.metric_card)._render_legend
  end

  def currency
    return unless (value_type = Card["#{card.metric_card.name}+value type"])
    return unless value_type.item_names[0] == "Money" &&
                  (currency = Card["#{card.metric_card.name}+currency"])
    currency.content
  end
end
