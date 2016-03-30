card_accessor :variables, type_id: Card::SessionID

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
  fail Card::Error, 'fail to parse formula for categorical input'
end

def complete_translation_table
  translation = translation_table
  if (all_options = metric_card.value_options)
    missing_options = translation.map { |opt, _val| all_options.delete opt }
    translation += missing_options.map { |opt| [opt, ''] }
  end
  translation
end

def variables_card
  fetch trait: :variables,
        new: {
          type: 'session',
          content: input_metrics.to_pointer_content
        }
end

format :html do
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
    target = '#modal-main-slot'
    # "#modal-#{card.cardname.safe_key}"
    content_tag :span, class: 'input-group' do
      button_tag class: 'pointer-item-add btn btn-default slotter',
                 type: 'button',
                 data: { toggle: 'modal', target: target },
                 href: path(layout: 'modal', view: :edit,
                            name: card.variables_card.name,
                            slot: {title: 'Choose Metric'}) do
        glyphicon('plus') + ' add metric'
      end
    end
  end

  view :rating_editor do |args|
    table_content = card.translation_table.map do |metric, weight|
      with_nest_mode :normal do
        subformat(metric)._render_weight_row(args.merge(weight: weight))
      end
    end
    sum_field =
      if table_content.empty?
        { content: sum_field, class: 'hidden' }
      else
        sum_field
      end
    table_content.push ['', sum_field]
    output [
      table_editor(table_content, %w(Metric Weight)),
      add_metric_button
    ]
  end


  def sum_field value=100
    text_field_tag 'weight_sum', value, class: 'weight-sum', disabled: true
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

  view :rating_core do |args|
    table_content =
      card.translation_table.map do |metric, weight|
        [subformat(metric)._render_thumbnail(args), weight]
      end
    table table_content, header: %w(Metric Weight)
  end

  view :categorical_core do |_args|
    table card.translation_table, header: %w(Metric Weight)
  end

  def get_nest_defaults _nested_card
    { view: :thumbnail }
  end
end

event :validate_cateogory_translation, :validate,
      when: proc { |c| c.translate_formula? } do
  # TODO: Check if there is a translation for all value options
end

event :validate_formula, :validate,
      when: proc { |c| c.wolfram_formula? } do
  not_on_whitelist =
    content.gsub(/\{\{([^}])+\}\}/, '').scan(/[a-zA-Z][a-zA-Z]+/)
           .reject do |word|
f    end
  if not_on_whitelist.present?
    errors.add :formula, "#{not_on_whitelist.first} forbidden keyword"
  end
end

# don't update if it's part of scored metric update
event :update_scores_for_formula, :prepare_to_store,
      on: :update, when: proc { |c| !c.supercard } do
  add_subcard left
  binding.pry
  left.update_values
end

# don't update if it's part of scored metric create
event :create_scores_for_formula, :prepare_to_store,
      on: :create, when: proc { |c| !c.supercard } do
  add_subcard left
  left.create_values
end

event :replace_variables, :prepare_to_validate,
      on: :save, changed: :content do
  format.each_nested_chunk do |chunk|
    metric_name = variables_card.input_metric_name chunk.referee_name
    content.gsub! chunk.referee_name.to_s, metric_name if metric_name
  end
end

def variable_name? v_name
  v_name =~ /M\d+/
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
end

def keyified
  content.gsub(/\{\{\s*([^}]+)\s*\}\}/) do |_match|
    "{{#{$1.to_name.key}}}"
  end
end

def input_values
  @input_values ||= fetch_input_values
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
  content.gsub(/\{\{([^}])+\}\}/,'').match(/^[\s\d+-\/*\.()]*$/)
end

def translate_formula?
  content =~ /^\{[^{}]+\}$/
end

def wolfram_formula?
  !ruby_formula? && !translate_formula?
end

private

def formula_interpreter
  if wiki_rating?
    WikiRatingFormula.new(self)
  elsif translate_formula?
    TranslateFormula.new(self)
  elsif ruby_formula?
    RubyFormula.new(self)
  else
    WolframFormula.new(self)
  end
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

# choose a company (and a year) or fetch all values
# @return [Hash] values in the form
#   { year => { company => { metric => value } } }
def fetch_input_values opts={}
  values = Hash.new { |h1, k1| h1[k1] = Hash.new { |h2, k2| h2[k2] = {} } }
  return values if input_metric_keys.empty?
  input_value_cards(opts).each_with_object(values) do |v_card, values|
    year = v_card.cardname.left_name.right
    company = v_card.cardname.left_name.left_name.right_name.key
    metric = v_card.cardname.left_name.left_name.left_name.key
    values[year][company][metric] = v_card.content
  end
end

# Searches for all metric value cards that are necessary to calculate all values
# If a company (and a year) is given it returns only the metric value cards that
# are needed to calculate the value for that company (and that year)
# @param [Hash] opts ({})
# @option [String] :company
# #option [String] :year
def input_value_cards opts={}
  ::Card.search value_cards_query(opts.merge(metrics: input_metric_keys))
end

def value_cards_query opts={}
  left_left = {}
  if opts[:metrics]
    left_left[:left] = { name: ['in'] + Array.wrap(opts[:metrics]) }
  end
  left_left[:right] = { name: opts[:company] } if opts[:company]
  {
    right: 'value',
    left: {
      left: left_left,
      right: opts[:year] || { type: 'year' }
    }
  }
end
