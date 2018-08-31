format :html do
  # MOVE TO HAML
  view :editor do
    unit_text = wrap_with :span, nest(card.metric_card, view: :legend),
                          class: "metric-unit"
    text_field(:content, class: "d0-card-content short-input") + " " + unit_text
  end
end
