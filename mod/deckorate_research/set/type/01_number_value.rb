include_set Abstract::Value

event :validate_numeric_value, :validate, on: :save do
  return true if value.to_s.number? || ::Answer.unknown?(value)
  errors.add :content, "Only numeric content is valid for this metric."
end

format :html do
  view :input do
    [
      text_field(:content, class: "d0-card-content short-input"),
      " ",
      nest(card.left, view: :legend),
      unknown_checkbox
    ]
  end

  def pretty_value
    @pretty_value ||= card.unknown_value? ? card.value : pretty_number
  end

  def pretty_number
    card.item_names.map { |n| humanized_number n }.join ", "
  end
end
