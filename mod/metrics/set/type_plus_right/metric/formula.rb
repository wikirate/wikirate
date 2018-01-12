include Abstract::Variable

def metric_name
  name.left
end

def metric_card
  left
end

def categorical?
  metric_card.respond_to?(:basic_metric_card) &&
    metric_card.basic_metric_card.categorical?
end

def wiki_rating?
  metric_card.metric_type_codename == :wiki_rating
end

def score?
  metric_card.metric_type_codename == :score
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
    if card.wiki_rating?
      _render_rating_editor
    elsif card.categorical?
      _render_categorical_editor
    elsif card.score?
      super()
    else
      _render_standard_formula_editor
    end
  end

  view :standard_formula_editor do
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
    _render_modal_slot(modal_id: "add-metric-slot", dialog_class: "large").html_safe
  end

  view :core do
    return _render_rating_core if card.wiki_rating?
    return _render_categorical_core if card.categorical?
    "<span>=</span><span>#{super()}</span>"
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

event :validate_formula_input, :validate, on: :save, changed: :content do
  input_chunks.each do |chunk|
    if variable_name?(chunk.referee_name)
      errors.add :formula, "invalid variable name: #{chunk.referee_name}"
    elsif !chunk.referee_card
      errors.add :formula, "input metric #{chunk.referee_name} doesn't exist"
    elsif ![MetricID, YearlyVariableID].include? chunk.referee_card.type_id
      errors.add :formula, "#{chunk.referee_name} has invalid type " \
                           "#{chunk.referee_card.type_name}"
    end
  end
end

def each_reference_out &block
  return super(&block) unless wiki_rating?
  translation_table.each do |key, _value|
    yield(key, Content::Chunk::Link::CODE)
  end
end

def input_chunks
  @input_chunks ||=
    begin
      content_obj = Card::Content.new(content, self, chunk_list: :formula)
      content_obj.find_chunks(Content::Chunk::FormulaInput)
    end
end

def input_cards
  @input_cards ||= input_names.map { |name| Card.fetch name }
end

def input_names
  @input_names ||=
    if score?
      [metric_card.basic_metric]
    elsif wiki_rating?
      translation_hash.keys
    else
      input_chunks.map { |chunk| chunk.referee_name.to_s }
    end
end

def input_keys
  @input_keys ||= input_names.map { |m| m.to_name.key }
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
