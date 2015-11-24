card_accessor :formula, type_id: PhraseID

WL_INTERPRETER = 'https://www.wolframcloud.com/objects/92f1e212-7875-49f9-888f-b5b4560b7686'

event :create_values,
      on: :create, before: :approve,
      when: proc { |c| c.formula.present? } do
  calculate_values.each_pair do |year, companies|
    companies.each_pair do |company, score|
      add_value company, year, score
    end
  end
end

event :update_values,
      on: :update, before: :approve,
      when: proc { |c| c.formula.present? } do
  value_cards = Card.search right: 'value',
                            left: { left: { left_id: id } }
  value_cards.each do |value_card|
    value_card.trash = true
    add_subcard value_card
  end

  calculate_values.each_pair do |year, companies|
    companies.each_pair do |company, value|
      if (card = subfield "+#{company}+#{year}+value")
        card.trash = false
        card.content = value
      else
        add_value company, year, value
      end
    end
  end
end

def update_value_for_company! company
  binding.pry
  values = fetch_values company: company
  values.each_pair do |year, metrics_with_values|
    score = calculate_single_value metrics_with_values
    metric_value_name = "#{metric_name}+#{company}+#{year}"
    if (metric_value = Card[metric_value_name])
      if (value_card = metric_value.fetch trait: :value)
        value_card.update_attributes content: score
      else
        Card.create name: "#{metric_value_name}+#{Card[:value].name}",
                    type_id: NumberID, content: score
      end
    else
      Card.create name: metric_value_name,
                  type_id: MetricValueID,
                  subcards: {
                    '+value' => { type_id: NumberID, content: score }
                  }
    end
  end
end

def add_value company, year, value
  add_subfield "+#{company}+#{year}",
               #type_id: MetricValueID,   # FIXME: can't use MetricValue because it needs a source
               subcards: { '+value' => { type_id: NumberID, content: value }
             }
end

def calculate_values
  input_values = fetch_values
  evaluate_formula input_values
end

def calculate_single_value metrics_with_values
  expr = insert_into_formula metrics_with_values
  evaluate_expression expr
end

def normalize_value value
  ("%.1f" % value).gsub(/\.0$/,'')
end

def evaluate_expression expr
  normalize_value evaluate_in_wolfram_cloud(expr).to_i
end

def evaluate_formula input_values
  wl_formula = prepare_formula input_values
  calc_values = evaluate_in_wolfram_cloud(wl_formula)
  result = Hash.new { |h,k| h[k] = {} }
  input_values.each_pair do |year, companies|
    companies.each_key.with_index do |company, i|
      result[year][company] = normalize_value calc_values[year.to_s][i]
    end
  end
  result
end

def extract_metrics
  formula.scan(/\{\{([^}]+)\}\}/).flatten
end

def extract_metric_keys
  extract_metrics.map { |m| m.to_name.key }
end

def insert_into_formula metrics_with_values
  result = formula
  metrics_with_values.each_pair do |metric, value|
    result.gsub! "{{#{metric}}}", value
  end
  result
end


# convert formula to a Wolfram Language expression
# Example:
# For formula {{metric A}}+{{metric B}} and two companies with
# values in 2014 and 2015 for those metics return
# (#[[1]]+#[[2]])&/@<|2015 -> {{1,2},{2,3}},2014-> {{4,5},{6,7}}|>
def prepare_formula values
  wl_formula = keyify_formula formula.clone
  metrics = extract_metric_keys
  metrics.each_with_index do |metric, i|
    # indices in Wolfram Language start with 1
    wl_formula.gsub!("{{#{ metric }}}", "#[[#{ i+1 }]]")
  end

  year_str = []
  values.each_pair do |year, companies|
    company_str = []
    companies.each do |company, metrics_with_values|
      values_str = metrics.map do |metric|
        # TODO: needs better default value handling
        metrics_with_values[metric] || 0
      end.join ','
     company_str << "{#{values_str}}"
    end
    year_str << "\"#{year}\" -> {#{company_str.join ','}}"
  end
  wl_input = year_str.join ','

  wl_func = "(#{wl_formula})&/@<| #{wl_input} |>"
end

def evaluate_in_wolfram_cloud expr
  uri = URI.parse(WL_INTERPRETER)
  # TODO: error handling
  response = Net::HTTP.post_form uri, 'expr' => expr
  result = JSON.parse(response.body)["Result"]
  JSON.parse result
end

def keyify_formula formula
  formula.gsub(/\{\{([^}]+)\}\}/) do |match|
    "{{#{match[1].to_name.key}}}"
  end
end

# choose a company or fetch all values
def fetch_values opts={}
  values = Hash.new { |h1, k1| h1[k1] = Hash.new { |h2, k2| h2[k2] = {} } }

  metrics = extract_metric_keys.unshift 'in'
  return values if metrics.size == 1
  value_cards =
    if opts[:company]
      binding.pry
      value_cards_for_company opts[:company], metrics
    else
      all_value_cards metrics
    end


  value_cards.each do |v_card|
    year = v_card.cardname.left_name.right
    company = v_card.cardname.left_name.left_name.right
    metric = v_card.cardname.left_name.left_name.left_name.key
    values[year][company][metric] = v_card.content
  end
  values
end


def value_cards opts={}
  query = {
    right: 'value',
    left: {
      left: {
      },
      right: opts[:year] || { type: 'year'},
    }
  }
end

def all_value_cards metrics
  Card.search right: 'value',
              left: {
                left:  { left: { name: metrics } },
                right: { type: 'year' }
              }
end

def value_cards_for_company company, metrics
  Card.search right: 'value',
              left: {
                left:  {
                  right: company,
                  left: { name: metrics }
                },
                right: { type: 'year' }
              }
end