delegate :calculator, :normalize_value, to: :left # left is metric

event :recalculate_on_formula_change, :integrate_with_delay,
      on: :save, changed: :content, priority: 5, when: :content? do
  metric_card.deep_answer_update
end
