event :flag_metric_answer_calculation, :prepare_to_store,
      on: :update, changed: :content do
  metric_card.calculation_in_progress!
end

# don't update if it's part of scored metric update
event :update_metric_answers, :integrate_with_delay, on: :update, changed: :content do
  metric_card.deep_answer_update
end

event :create_dummy_answers, :finalize,
      on: :create, changed: :content, when: :content? do
  metric_card.initial_calculation_in_progress!
end

# don't update if it's part of scored metric create
event :create_metric_answers, :integrate_with_delay,
      on: :create, changed: :content, when: :content?  do
  # reload set modules seems to be no longer necessary
  # it used to happen at this point that left has type metric but
  # set_names includes "Basic+formula+*type plus right"
  # reset_patterns
  # include_set_modules
  metric_card.deep_answer_update true
end

def calculator
  calculator_class.new parser, &method(:normalize_value)
end

def calculator_class
  metric_card&.calculator_class || ::Formula.calculator_class(parser.formula)
end
