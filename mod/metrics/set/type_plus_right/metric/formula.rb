include_set Abstract::Variable
include_set Abstract::Pointer
include_set Abstract::MetricChild, generation: 1

def categorical?
  score? && metric_card.categorical?
end

format :html do
  def new_view_hidden
    hidden_tags success: { id: card.name.left }
  end

  def new_form_opts
    super().merge "data-slot-selector" => ".card-slot.TYPE-metric"
  end

  def edit_form_opts
    { "data-slot-selector" => ".card-slot.TYPE-metric" }
  end

  def edit_view_hidden
    new_view_hidden
  end

  view :editor do
    with_hidden_content do
      _render card.metric_card.formula_editor
    end
  end

  def with_hidden_content
    hidden = card.metric_card.hidden_content_in_formula_editor?
    (hidden ? _render_hidden_content_field : "") + yield
  end

  view :standard_formula_editor, tags: :unknown_ok do
    output [formula_text_area, _render_variables]
  end

  def formula_text_area
    text_area :content, rows: 5, class: "d0-card-content",
                        "data-card-type-code": card.type_code
  end

  view :new do
    super() + add_metric_modal_slot
  end

  view :edit do
    voo.hide :toolbar
    super() + add_metric_modal_slot
  end

  def add_metric_modal_slot
    modal_slot "add-metric-slot", "large"
  end

  view :core do
    render card.metric_card.formula_core
  end

  view :standard_formula_core do
    "<span>=</span><span>#{process_content _render_raw}</span>"
  end

  def default_nest_view
    :formula_thumbnail
  end
end

event :validate_formula, :validate, when: :wolfram_formula? do
  formula_errors = calculator.validate_formula
  return if formula_errors.empty?
  formula_errors.each do |msg|
    errors.add :formula, msg
  end
end

def each_reference_out &block
  return super(&block) unless rating?
  translation_table.each do |key, _value|
    yield(key, Content::Chunk::Link::CODE)
  end
end

def normalize_value value
  metric_card.normalize_value value
end

def ruby_formula?
  calculator_class == ::Formula::Ruby
end

def translate_formula?
  calculator_class == ::Formula::Translation
end

def wolfram_formula?
  calculator_class ==  ::Formula::Wolfram
end
