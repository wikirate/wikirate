include_set Abstract::Value

event :validate_numeric_value, :validate do
  return true if number?(value) || Answer.unknown?(value)
  errors.add :content, "Only numeric content is valid for this metric."
end

format :html do
  # MOVE TO HAML
  view :editor do
    unit_text = wrap_with :span, nest(card.metric_card, view: :legend),
                          class: "metric-unit"
    text_field(:content, class: "d0-card-content short-input") + " " + unit_text
  end

  def pretty_value
    @pretty_value ||= card.unknown_value? ? card.value : pretty_number
  end

  def pretty_number
    card.item_names.map { |n| humanized_number n }.join ", "
  end
end
