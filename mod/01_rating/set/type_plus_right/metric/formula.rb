card_accessor :formula_input, type: 'session'

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

def each_references_out &block
  return super(&block) unless wiki_rating?
  translation_table.each do |key, _value|
    block.call(key, Content::Chunk::Link::CODE)
  end
end

# converts a categorical formula content to an array
# @return [Array] list of pairs of value option and the value for that option
def translation_table
  JSON.parse(content).to_a
rescue JSON::ParserError => e
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

format :html do
  view :editor do |args|
    return _render_rating_editor(args) if card.wiki_rating?
    return _render_categorical_editor(args) if card.categorical?

    formula_input =
      card.fetch trait: :formula_input,
                 new: {
                   type: 'session',
                   content: card.input_metrics.to_pointer_content
                 }

    super(args) + with_nest_mode(:normal) do
      subformat(formula_input)._render_core(args)
    end
  end

  view :rating_editor do |args|
    table_content = card.translation_table.map do |metric, weight|
      metric_thumbnail = with_nest_mode :normal do
        subformat(metric)._render_thumbnail(args)
      end
      [{ content: metric_thumbnail, 'data-key': metric },
        text_field_tag('pair_value', weight, class: 'metric-weight')
      ]
    end
    table_content.unshift ['Metric','Weight']
    table_content.push ['Sum', text_field_tag('weight_sum', 100, class:
      'weight-sum' )]
    table_editor table_content
  end

  view :categorical_editor do |_args|
    table_content = card.complete_translation_table.map do |key, value|
      [{content: key, 'data-key': key}, text_field_tag('pair_value', value)]
    end
    table_content.unshift ['Option','Value']
    table_editor table_content
  end

  # @param [Array] table_content 2-dimensional array with the data for the
  # table; first row is the header
  def table_editor table_content
    table(table_content, class: 'pairs-editor', header: true) +
      hidden_field(:content, class: 'card-content')
  end

  view :core do |args|
    return _render_rating_core(args) if card.wiki_rating?
    return _render_categorical_core(args) if card.categorical?
    "= #{super(args)}"
  end

  view :rating_core do |_args|
    table card.translation_table.unshift(['Metric','Weight']), header: true
  end

  view :categorical_core do |_args|
    table card.translation_table.unshift(['Option','Value']), header: true
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
      when: proc { |c| c.wolfram_formula?} do
  not_on_whitelist =
    content.gsub(/\{\{([^}])+\}\}/,'').scan(/[a-zA-Z][a-zA-Z]+/)
    .reject do |word|
      WL_FORMULA_WHITELIST.include? word
    end
  if not_on_whitelist.present?
    errors.add :formula, "#{not_on_whitelist.first} forbidden keyword"
  end
end

# don't update if it's part of scored metric update
event :update_scores_for_formula, :prepare_to_store, on: :update,
                         when: proc { |c| !c.supercard } do
  add_subcard left
  left.update_values
end

# don't update if it's part of scored metric create
event :create_scores_for_formula, :prepare_to_store,  on: :create,
                         when: proc { |c| !c.supercard } do
  add_subcard left
  left.create_values
end

def calculate_all_values
  formula_interpreter.evaluate.each_pair do |year, companies|
    companies.each_pair do |company, value|
      yield company, year, value if value
    end
  end
end

def calculate_values_for company
  values = fetch_input_values company: company
  values.each_pair do |year, companies|
    metrics_with_values = companies[company.to_name.key]
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
  if translate_formula?
    TranslateFormula.new(self)
  elsif ruby_formula?
    RubyFormula.new(self)
  else
    WolframFormula.new(self)
  end
end

def extract_metrics
  content.scan(/\{\{([^|}]+)(?:\|[^}]*)?\}\}/).flatten
end

# choose a company or fetch all values
def fetch_input_values opts={}
  values = Hash.new { |h1, k1| h1[k1] = Hash.new { |h2, k2| h2[k2] = {} } }
  return values if input_metric_keys.empty?
  value_cards =
    if opts[:company]
      input_value_cards_for opts[:company]
    else
      all_input_value_cards
    end

  value_cards.each do |v_card|
    year = v_card.cardname.left_name.right
    company = v_card.cardname.left_name.left_name.right_name.key
    metric = v_card.cardname.left_name.left_name.left_name.key
    values[year][company][metric] = v_card.content
  end
  values
end

def all_input_value_cards
  Card.search value_cards_query(metrics: input_metric_keys)
end

def input_value_cards_for company
  Card.search value_cards_query(company: company, metrics: input_metric_keys)
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
      right: opts[:year] || { type: 'year' },
    }
  }
end
