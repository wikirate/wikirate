format :html do
  view :raw_value do
    nest value_card, view: :raw_value
    raw_value =
      if value_card.metric_type == :score
        base_metric_value(value_card).value
      else
        value_card.value
      end
    wrap_with(:span, raw_value, class: "metric-value")
  end
end
