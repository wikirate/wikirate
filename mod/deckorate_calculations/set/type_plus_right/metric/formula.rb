include_set Abstract::MetricChild, generation: 1
include_set Abstract::CalcTrigger

delegate :metric_type_codename, :metric_type_card, :variables_card,
         :calculator_class, :calculator, :normalize_value,
         :researched?, :calculated?, :rating?, :score?, to: :metric_card

delegate :ok_to_delete?, to: :metric_card

event :validate_formula, :validate, changed: :content do
  formula_errors = calculator.detect_errors
  return if formula_errors.empty?
  formula_errors.each do |msg|
    errors.add :formula, msg
  end
end

format :html do
  delegate :score?, to: :card

  before(:edit) {  voo.hide :edit_type_row }

  view :titled_content do
    return super() if score?

    nest card.variables_card, view: :core
  end

  def input_type
    :formula
  end

  def formula_input
    haml :formula_input
  end

  def edit_fields
    [[card.variables_card, { title: "" }], [card, { title: "" }]]
  end

  def multi_card_editor?
    parent.card != card
  end

  def editor_tabs
    tabs CoffeeScript: code_mirror_input,
         JavaScript: haml(:formula_as_javascript),
         Answers: haml(:answer_board),
         Help: haml(:editor_help)
    #:Answers)
  end

  # TODO: move to mod
  def code_mirror_input
    text_area :content, rows: 5,
                        class: "d0-card-content codemirror-editor-textarea",
                        "data-codemirror-mode": "coffee"
  end

  def default_nest_view
    :bar
  end
end

# TODO: explain!?!
# what was the situation where a metric formula was seen as a possible asset inputter?
def asset_inputter?
  false
end
