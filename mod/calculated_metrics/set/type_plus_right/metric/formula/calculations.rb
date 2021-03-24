delegate :calculator, :normalize_value, to: :left # left is metric

# often overwritten in metric
def calculator_class
  ::Formula.calculator_class parser.formula
end

event :create_dummy_answers, :finalize,
      on: :create, changed: :content, when: :content? do
  metric_card.initial_calculation_in_progress!
end

event :flag_as_calculating, :prepare_to_store,
      on: :update, changed: :content, when: :content? do
  metric_card.calculation_in_progress!
end

# the following two events had a note saying
# "don't update if it's part of scored metric update".
#
# I don't understand the meaning of or the rationale for this message. - efm 3/2021

event :update_metric_answers, :integrate_with_delay,
      on: :save, changed: :content, when: :content? do
  metric_card.deep_answer_update(@action == :create)
end
