include_set Abstract::MetricChild, generation: 1

delegate :metric_type_codename, :metric_type_card, :calculator_class,
         :researched?, :calculated?, :rating?, to: :metric_card

event :validate_formula, :validate, when: :javascript_formula?, changed: :content do
  formula_errors = calculator.detect_errors
  return if formula_errors.empty?
  formula_errors.each do |msg|
    errors.add :formula, msg
  end
end

def categorical?
  score? && metric_card.categorical?
end

def translation?
  categorical? || rating?
end

def help_rule_card
  metric_type_card.first_card&.fetch :help
end

def javascript_formula?
  calculator_class == ::Calculate::JavaScript
end

def translate_formula?
  calculator_class == ::Calculate::Translation
end

format :html do
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

  view :input do
    _render card.metric_card.formula_editor
  end

  view :standard_formula_editor, unknown: true do
    output [text_area_input]
  end

  view :core do
    render card.metric_card.formula_core
  end

  view :standard_formula_core, template: :haml, cache: :never

  def default_nest_view
    :bar
  end
end

format :json do
  view(:content) { card.json_content }
end

def json_content
  translation? ? translation_hash : content unless researched?
end
