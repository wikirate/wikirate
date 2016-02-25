card_accessor :formula_input, type: 'session'

WL_FORMULA_WHITELIST = ::Set.new ['Boole']

def metric_name
  cardname.left
end

format :html do
  view :editor do |args|
    metrics_list = card.input_metrics.map { |m| "[[#{m}]]" }.join "\n"
    formula_input = card.fetch trait: :formula_input,
                              new: {
                                type: 'session',
                                content:  metrics_list
                              }

    super(args) + with_inclusion_mode(:normal) do
      subformat(formula_input)._render_core(args)
    end
  end
end

event :approve_formula, before: :approve do
  not_on_whitelist =
    content.gsub(/\{\{([^}])+\}\}/,'').scan(/[a-zA-Z][a-zA-Z]+/)
    .reject do |word|
      WL_FORMULA_WHITELIST.include? word
    end
  if not_on_whitelist.present?
    errors.add :formula, "#{not_on_whitelist.first} forbidden keyword"
  end
end

event :update_scores_for_formula, on: :update, before: :approve,
                         when: proc { |c| !c.supercard } do # don't update if it's part of scored metric update
  add_subcard left
  left.update_values
end

event :create_scores_for_formula, on: :create, before: :approve,
                         when: proc { |c| !c.supercard } do # don't update if it's part of scored metric create
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

private

def formula_interpreter
  if ruby_formula?
    RubyFormula.new(self)
  else
    WolframFormula.new(self)
  end
end

def extract_metrics
  content.scan(/\{\{([^}]+)\}\}/).flatten
end

# allow only numbers, whitespace, mathematical operations and args references
def ruby_formula?
  content.gsub(/\{\{([^}])+\}\}/,'').match(/^[\s\d+-\/*\.()]*$/)
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
