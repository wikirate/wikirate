include_set Abstract::MetricChild, generation: 1
include_set Abstract::CalcTrigger

delegate :metric_type_codename, :metric_type_card, :variables_card,
         :calculator_class, :calculator, :normalize_value,
         :researched?, :calculated?, :rating?, to: :metric_card

event :validate_formula, :validate, changed: :content do
  formula_errors = calculator.detect_errors
  return if formula_errors.empty?
  formula_errors.each do |msg|
    errors.add :formula, msg
  end
end

format :html do
  before(:edit) {  voo.hide :edit_type_row }

  view :titled_content do
    [nest(card.variables_card, view: :core, title: "Variables"), render_content]
  end

  def input_type
    :formula
  end

  def formula_input
    haml :formula_input
  end

  def edit_fields
    [[card.variables_card, { title: "Variables" }], [card, { title: "Formula" }]]
  end

  def multi_card_editor?
    depth.zero?
  end

  def editor_tabs
    tabs({ Edit: ace_editor_input,
           JavaScript: haml(:formula_as_javascript),
           Answers: haml(:answer_board),
           Help: haml(:editor_help) },
         :Answers)
  end

  # def new_success
  #   { mark: card.name.left }
  # end
  #
  # def new_form_opts
  #   super().merge "data-slot-selector" => ".card-slot.TYPE-metric"
  # end
  #
  # def edit_form_opts
  #   { "data-slot-selector" => ".card-slot.TYPE-metric",
  #     "data-slot-error-selector" => ".RIGHT-formula.edit_form-view" }
  # end
  #
  # def edit_success
  #   new_success
  # end

  def default_nest_view
    :bar
  end
end
