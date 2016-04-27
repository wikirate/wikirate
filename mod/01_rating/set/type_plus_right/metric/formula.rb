include Abstract::Variable

WL_FORMULA_WHITELIST = ::Set.new ['Boole']

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

def each_reference_out &block
  return super(&block) unless wiki_rating?
  translation_table.each do |key, _value|
    block.call(key, Content::Chunk::Link::CODE)
  end
end

# converts a categorical formula content to an array
# @return [Array] list of pairs of value option and the value for that option
def translation_table
  translation_hash.to_a
end

def translation_hash
  return {} unless content.present?
  JSON.parse(content)
rescue JSON::ParserError => _e
  content = '{}'
  return {}
  #fail Card::Error, 'fail to parse formula for categorical input'
end

def complete_translation_table
  translation = translation_table
  all_options = if score?
                  metric_card.basic_metric_card.value_options
                else
                  metric_card.value_options
                end
  if all_options
    missing_options = all_options - translation_hash.keys
    translation += missing_options.map { |opt| [opt, ''] }
  end
  translation
end

def variables_card
  v_card = metric_card.fetch trait: :variables, new: { type: 'session' }
  if v_card.content.blank?
    v_card.content = input_metrics.to_pointer_content
  end
  v_card
end

format :html do
  def default_new_args args
    super(args)
    args[:hidden] = { success: { id:  card.cardname.left } }
    args[:form_opts] = {
      'data-slot-selector' => '.card-slot.TYPE-metric'
    }
  end

  def default_edit_args args
    super(args)
    args[:hidden] = { success: { id:  card.cardname.left } }
    args[:form_opts] = {
      'data-slot-selector' => '.card-slot.TYPE-metric'
    }
  end

  view :editor do |args|
    return _render_rating_editor(args) if card.wiki_rating?
    return _render_categorical_editor(args) if card.categorical?
    return super(args) if card.score?
    output [
      super(args),
      _render_variables(args),
      add_metric_button
    ]
  end

  view :variables do |args|
    with_nest_mode(:normal) do
      subformat(card.variables_card)._render_open(
        args.merge(optional_header: :hide, optional_menu: :hide)
      ).html_safe
    end
  end

  def add_metric_button
    target = '#modal-add-metric-slot'
    # "#modal-#{card.cardname.safe_key}"
    output [
      (content_tag :span, class: 'input-group' do
        button_tag class: 'pointer-item-add btn btn-default slotter',
                   type: 'button',
                   data: { toggle: 'modal', target: target },
                   href: path(layout: 'modal', view: :edit,
                              name: card.variables_card.name,
                              slot: {title: 'Choose Metric'}) do
          glyphicon('plus') + ' add metric'
        end
      end),
      _render_modal_slot(modal_id: 'add-metric-slot',
                         dialog_class: 'large').html_safe
    ]
  end

  view :categorical_editor do |_args|
    table_content = card.complete_translation_table.map do |key, value|
      [{ content: key, 'data-key': key }, text_field_tag('pair_value', value)]
    end
    table_editor table_content, %w(Option Value)
  end

  # @param [Array] table_content 2-dimensional array with the data for the
  # table; first row is the header
  def table_editor table_content, header=nil
    table(table_content, class: 'pairs-editor', header: header) +
      hidden_field(:content, class: 'card-content')
  end

  view :core do |args|
    return _render_rating_core(args) if card.wiki_rating?
    return _render_categorical_core(args) if card.categorical?
    "= #{super(args)}"
  end


  view :categorical_core do |_args|
    table card.translation_table, header: %w(Metric Weight)
  end

  def get_nest_defaults _nested_card
    { view: :thumbnail }
  end
end

event :validate_category_translation, :validate,
      when: proc { |c| c.translate_formula? } do
  # TODO: Check if there is a translation for all value options
end

event :validate_formula, :validate,
      when: proc { |c| c.wolfram_formula? } do
  not_on_whitelist =
    content.gsub(/\{\{([^}])+\}\}/, '').gsub(/"[^"]+"/,'')
      .scan(/[a-zA-Z][a-zA-Z]+/).reject do |word|
      WL_FORMULA_WHITELIST.include? word
    end
  if not_on_whitelist.present?
    errors.add :formula, "#{not_on_whitelist.first} forbidden keyword"
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
  add_subcard metric_card.metric_value_name(company, year),
               type_id: MetricValueID,
               subcards: {
                 '+value' => { type_id: NumberID, content: value }
               }
end

event :replace_variables, :prepare_to_validate,
      on: :save, changed: :content do
  format.each_nested_chunk do |chunk|
    next unless variable_name?(chunk.referee_name)
    metric_name = variables_card.input_metric_name chunk.referee_name
    content.gsub! chunk.referee_name.to_s, metric_name if metric_name
  end
end


event :validate_formula_input, :validate,
      on: :save, changed: :content do
  format.each_nested_chunk do |chunk|
    case
    when variable_name?(chunk.referee_name)
      errors.add :formula, "invalid variable name: #{chunk.referee_name}"
    when !chunk.referee_card
      errors.add :formula, "input metric #{chunk.referee_name} doesn't exist"
    when chunk.referee_card.type_id != MetricID
      errors.add :formula, "#{chunk.referee_name} is not a metric"
    end
  end
end

def calculate_all_values
  formula_interpreter.evaluate.each_pair do |year, companies|
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
    fail Card::Error, '#calculate_values_for: no company given'
  end
  values = fetch_input_values opts
  values.each_pair do |year, companies|
    metrics_with_values = companies[opts[:company].to_name.key]
    value = formula_interpreter.evaluate_single_input metrics_with_values
    yield year, value
  end
  if opts[:year] && values.empty?
    yield opts[:year], nil
  end
end

def keyified
  content.gsub(/\{\{\s*([^}]+)\s*\}\}/) do |_match|
    "{{#{$1.to_name.key}}}"
  end
end

def input_values
  @input_values ||= fetch_input_values
end


def input_cards
 input_metrics
end

def input_metric_keys
  @metric_keys ||= input_metrics.map { |m| m.to_name.key }
end

def input_metrics
  @input_metrics ||= extract_metrics
end

def normalize_value value
  ('%.1f' % value).gsub(/\.0$/, '') if value
end

# allow only numbers, whitespace, mathematical operations and args references
def ruby_formula?
  formula_interpreter.class == RubyFormula
end

def translate_formula?
  formula_interpreter.class == TranslateFormula
end

def wolfram_formula?
  formula_interpreter.class == WolframFormula
end

private

def formula_interpreter
  @formula_interpreter = ::Formula.new_formula(self)
end

# find all metrics that are part of the formula
def extract_metrics
  if metric_card.metric_type_codename == :score
    [metric_card.basic_metric]
  elsif wiki_rating?
    translation_hash.keys
  else
    content.scan(/\{\{([^|}]+)(?:\|[^}]*)?\}\}/).flatten
  end
end


