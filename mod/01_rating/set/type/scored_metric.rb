card_accessor :formula, type_id: PhraseID

WL_INTERPRETER = 'https://www.wolframcloud.com/objects/92f1e212-7875-49f9-888f-b5b4560b7686'

event :create_scores,
      on: :create, before: :approve,
      when: proc { |c| c.formula.present? } do
        binding.pry
  calculate_scores.each_pair do |year, companies|
    companies.each_pair do |company, score|
      add_score company, year, score
    end
  end
end

event :update_scores,
      on: :update, before: :approve,
      when: proc { |c| c.formula.present? } do
  value_cards = Card.search right: 'value',
                            left: { left: { left_id: metric_id } }
  value_cards.trash = true
  add_subcard value_card

  calculate_scores.each_pair do |year, companies|
    companies.each_pair do |company, score|
      if (card = subfield "+#{company}+#{year}+value")
        card.trash = false
        card.content = score
      else
        add_score company, year, value
      end
    end
  end
end

def update_score_for_company! company
  values = fetch_values_for_company company
  values.each_pair do |year, metrics_with_values|
    score = calculate_score metrics_with_values
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

def add_score company, year, value
  add_subfield "+#{company}+#{year}",
##               type_id: MetricValueID,   # FIXME: can't use MetricValue because it needs a source
               subcards: { '+value' => { type_id: NumberID, content: value }
               #'+source' => '[[_lll+formula]]'
             }
end

def calculate_scores
  values = fetch_values
  wl_formula = prepare_formula values
  scores = evaluate_in_wolfram_cloud(wl_formula)
  result = Hash.new { |h,k| h[k] = {} }
  values.each_pair do |year, companies|
    companies.each_key.with_index do |company, i|
      result[year][company] = normalize_score scores[year.to_s][i]
    end
  end
  result
end

def calculate_single_score metrics_with_values
  wl_formula = insert_into_formula metrics_with_values
  result = evaluate_in_wolfram_cloud(wl_formula).to_i
  normalize_score result
end

def normalize_score score
  return 0 if score < 0
  return 10 if score > 10
  score
end

def extract_metrics
  formula.scan(/\{\{([^}]+)\}\}/).flatten
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
  wl_formula = formula
  metrics = extract_metrics
  metrics.each_with_index do |metric, i|
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


# choose a company or fetch all values
def fetch_values opts={}
  metrics = extract_metrics.unshift 'in'
  value_cards =
    if opts[:company]
      value_cards_for_company opts[:company], metrics
    else
      all_value_cards metrics
    end

  values = Hash.new { |h1, k1| h1[k1] = Hash.new { |h2, k2| h2[k2] = {} } }
  value_cards.each do |v_card|
    year = v_card.cardname.left_name.right
    company = v_card.cardname.left_name.left_name.right
    metric = v_card.cardname.left_name.left_name.left
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
