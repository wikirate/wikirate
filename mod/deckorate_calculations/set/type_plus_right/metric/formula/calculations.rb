delegate :calculator, :normalize_value, to: :left # left is metric

# often overwritten in metric
def calculator_class
  ::Calculate.calculator_class parser.formula
end

event :update_calculated_answers, :integrate_with_delay,
      on: :save, changed: :content, priority: 5, when: :content? do
  metric_card.deep_answer_update
end
