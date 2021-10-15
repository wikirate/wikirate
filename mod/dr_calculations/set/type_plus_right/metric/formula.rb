include_set Abstract::Variable
include_set Abstract::Pointer
include_set Abstract::MetricChild, generation: 1

delegate :metric_type_codename, :metric_type_card, :researched?, :calculated?, :rating?,
         to: :metric_card

def categorical?
  score? && metric_card.categorical?
end

def translation?
  categorical? || rating?
end

def help_rule_card
  metric_type_card.first_card&.fetch :help
end

event :validate_formula, :validate, when: :syntax_formula?, changed: :content do
  formula_errors = calculator.detect_errors
  return if formula_errors.empty?
  formula_errors.each do |msg|
    errors.add :formula, msg
  end
end

def each_reference_out &block
  return super(&block) unless rating?
  translation_table.each do |key, _value|
    yield key, Content::Chunk::Link::CODE
  end
end

def replace_references old_name, new_name
  return super unless rating?
  content.gsub old_name, new_name
end

def javascript_formula?
  # expected to be a short-term solution
  content.lines.first&.match? "CoffeeScript"
end

def syntax_formula?
  calculator.is_a? Calculate::NestCalculator
end

def ruby_formula?
  calculator_class == ::Calculate::Ruby
end

def translate_formula?
  calculator_class == ::Calculate::Translation
end

def wolfram_formula?
  calculator_class == ::Calculate::Wolfram
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
    with_hidden_content do
      _render card.metric_card.formula_editor
    end
  end

  def with_hidden_content
    hidden = card.metric_card.hidden_content_in_formula_editor?
    (hidden ? _render_hidden_content_field : "") + yield
  end

  view :standard_formula_editor, unknown: true do
    output [text_area_input, _render_variables]
  end

  view :core do
    render card.metric_card.formula_core
  end

  view :standard_formula_core, template: :haml, cache: :never

  def default_nest_view
    :bar
  end
end

def standard_display_formula
  if javascript_formula?
    # no "CoffeeScript" tag at top
    standard_formula
  else
    # no line breaks
    content
  end
end

format :json do
  view(:content) { card.json_content }
end

def json_content
  return if researched?

  translation? ? translation_hash : content
end
