delegate :calculator, :normalize_value, to: :left # left is metric

# often overwritten in metric
def calculator_class
  if javascript_formula?
    ::Formula::JavaScript
  else
    ::Formula.calculator_class parser.formula
  end
end

# the following two events had a note saying
# "don't update if it's part of scored metric update".
#
# I don't understand the meaning of or the rationale for this message. - efm 3/2021

event :update_metric_answers, :integrate_with_delay,
      on: :save, changed: :content, when: :content? do
  metric_card.deep_answer_update
end
