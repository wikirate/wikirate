include Abstract::Variable

def metric_name
  cardname.left
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
  def default_new_args args
    super(args)
    args[:hidden] ||= {}
    args[:hidden][:success] = { id:  card.cardname.left }
    args[:form_opts] = {
      "data-slot-selector" => ".card-slot.TYPE-metric"
    }
  end

  def default_edit_args args
    super(args)
    args[:hidden] ||= {}
    args[:hidden][:success] = { id:  card.cardname.left }
    args[:form_opts] = {
      "data-slot-selector" => ".card-slot.TYPE-metric"
    }
  end

  view :editor do |args|
    return _render_rating_editor(args) if card.wiki_rating?
    return _render_categorical_editor(args) if card.categorical?
    return super(args) if card.score?
    output [
      text_area(:content,
                rows: 5,
                class: "card-content",
                "data-card-type-code" => card.type_code),
      _render_variables(args),
      add_metric_button
    ]
  end

  def add_metric_button
    target = '#modal-add-metric-slot'
    # "#modal-#{card.cardname.safe_key}"
    output [
      (content_tag :span, class: "input-group" do
        button_tag class: "pointer-item-add btn btn-default slotter",
                   type: "button",
                   data: { toggle: "modal", target: target },
                   href: path(layout: "modal", view: :edit,
                              mark: card.variables_card.name,
                              slot: { title: "Choose Metric" }) do
          glyphicon("plus") + " add metric"
        end
      end),
      _render_modal_slot(modal_id: "add-metric-slot",
                         dialog_class: "large").html_safe
    ]
  end

  view :core do |args|
    return _render_rating_core(args) if card.wiki_rating?
    return _render_categorical_core(args) if card.categorical?
    "= #{super(args)}"
  end

  def default_nest_view
    :thumbnail
  end
end

event :validate_formula, :validate,
      when: proc { |c| c.wolfram_formula? } do
  formula_errors = calculator.validate_formula
  return if formula_errors.empty?
  formula_errors.each do |msg|
    errors.add :formula, msg
  end
end

# don't update if it's part of scored metric update
event :update_metric_values, :prepare_to_store,
      on: :update, changed: :content do
  metric_card.value_cards.each do |value_card|
    value_card.trash = true
    add_subcard value_card
  end
  calculate_all_values do |company, year, value|
    metric_value_name = metric_card.metric_value_name(company, year)
    next if subcard metric_value_name
    if (card = subcard "#{metric_value_name}+value")
      card.trash = false
      card.content = value
    else
      add_value company, year, value
    end
  end
end

# don't update if it's part of scored metric create
event :create_metric_values, :prepare_to_store,
      on: :create, changed: :content, when: proc { |c| c.content.present? }  do
  # reload set modules seems to be no longer necessary
  # it used to happen at this point that left has type metric but
  # set_names includes "Basic+formula+*type plus right"
  # reset_patterns
  # include_set_modules
  calculate_all_values do |company, year, value|
    add_value company, year, value
  end
end

def add_value company, year, value
  return unless value.present?
  type_id = value.number? ? NumberID : PhraseID
  add_subcard metric_card.metric_value_name(company, year),
              type_id: MetricValueID,
              subcards: {
                "+value" => { type_id: type_id, content: value }
              }
end

event :validate_formula_input, :validate,
      on: :save, changed: :content do
  input_chunks.each do |chunk|
    case
    when variable_name?(chunk.referee_name)
      errors.add :formula, "invalid variable name: #{chunk.referee_name}"
    when !chunk.referee_card
      errors.add :formula, "input metric #{chunk.referee_name} doesn't exist"
    when chunk.referee_card.type_id != MetricID &&
      chunk.referee_card.type_id != YearlyVariableID
      errors.add :formula, "#{chunk.referee_name} has invalid type " \
                           "#{chunk.referee_card.type_name}"
    end
  end
end

def calculate_all_values
  calculator.result.each_pair do |year, companies|
    companies.each_pair do |company, value|
      yield company, year, value if value
    end
  end
end

# @param [Hash] opts
# @option opts [String] :company
# @option opts [String] :year optional
def calculate_values_for opts={}
  unless opts[:company]
    raise Card::Error, '#calculate_values_for: no company given'
  end
  no_value = true
  calculator.result(opts).each_pair do |year, companies|
    no_value = false
    value = companies[opts[:company]]
    yield year, value
  end
  yield opts[:year], nil if opts[:year] && no_value
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

private

def calculator_class
  @calculator_class ||=
    if wiki_rating?
      ::Formula::WikiRating
    elsif ::Formula::Translation.valid_formula? content
      ::Formula::Translation
    elsif ::Formula::Ruby.valid_formula? content
      ::Formula::Ruby
    else
      ::Formula::Wolfram
    end
end

def calculator
  @calculator ||= calculator_class.new self
end
