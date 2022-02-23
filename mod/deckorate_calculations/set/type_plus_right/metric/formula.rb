include_set Abstract::MetricChild, generation: 1

delegate :metric_type_codename, :metric_type_card,
         :calculator_class, :calculator, :normalize_value,
         :researched?, :calculated?, :rating?, to: :metric_card

event :validate_formula, :validate, changed: :content do
  formula_errors = calculator.detect_errors
  return if formula_errors.empty?
  formula_errors.each do |msg|
    errors.add :formula, msg
  end
end

event :recalculate_on_formula_change, :integrate_with_delay,
      on: :save, changed: :content, priority: 5, when: :content? do
  metric_card.deep_answer_update
end

def help_rule_card
  metric_type_card.first_card&.fetch :help
end

format :html do
  view :titled_content do
    [nest(card.metric_card.variables_card, view: :core), render_content]
  end

  def new_success
    { mark: card.name.left }
  end

  def new_form_opts
    super().merge "data-slot-selector" => ".card-slot.TYPE-metric"
  end

  def edit_form_opts
    { "data-slot-selector" => ".card-slot.TYPE-metric",
      "data-slot-error-selector" => ".RIGHT-formula.edit_form-view" }
  end

  def edit_success
    new_success
  end

  def default_nest_view
    :bar
  end
end
