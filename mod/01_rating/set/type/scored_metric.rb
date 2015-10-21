card_accessor :formula, type_id: PhraseID

event :create_scores,
      on: :create, before: :store,
      when: proc { formula.present? } do
  values = fetch_all_values_for_formula
  values.each_pair do |year, companies|
    companies.each_pair do |company, metrics_with_values|
      score = calculate_score metrics_with_values
      add_score company, year, score
    end
  end
end

event :update_scores,
      on: :update, before: :store,
      when: proc { formula.present? } do
  value_cards = Card.search right: 'value',
                            left: { left: { left_id: metric_id } }
  value_cards.trash = true
  add_subcard value_card

  values = fetch_all_values_for_formula
  values.each_pair do |year, companies|
    companies.each_pair do |company, metrics_with_values|
      score = calculate_score metrics_with_values
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
               type_id: MetricValueID,
               subcards: { '+value' => { type_id: NumberID, content: value } }
end

def calculate_score metrics_with_values
  wl_formula = insert_into_formula metrics_with_values
  result = evaluate_in_wolfram_cloud(wl_formula).to_i

  return 0 if result < 0
  return 10 if result > 10
  result
end

def extract_metrics
  formula.scan(/\{\{([^}])+\}\}/).flatten
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
def prepare_formula
  wl_formula = formula
  metrics = extract_metrics
  metrics.each_with_index do |metric, i|
    wl_formula.gsub("{{#{ metric }}}", "#[[#{ i+1 }]]")
  end

  values = fetch_all_values_for_formula
  year_str = []
  values.each_pair do |year, companies|
    company_str = []
    companies.each do |company, metrics_with_values|
      values_str = metrics.map do |metric|
        metrics_with_values[metric]
      end.join ','
     company_str << "{#{values_str}}"
    end
    year_str += "#{year} -> {#{company_str.join ','}}"
  end
  wl_input = year_str.join ','

  wl_func = "(#{wl_formula})&/@<| #{wl_input} |>"
end

def evaluate_in_wolfram_cloud expr
  uri = URI.parse(WL_INTERPRETER)
  Net::HTTP.post_form uri, 'expr' => expr
end

def fetch_all_values_for_fomula
  metrics = extract_metrics.unshift 'IN'
  values = Hash.new { |h1, k1| h1[k1] = Hash.new { |h2, k2| h2[k2] = {} } }
  value_cards = Card.search right: 'value',
                            left: {
                              left:  { left: { name: metrics } },
                              right: { type: 'year' }
                            }
  value_cards.each do |v_card|
    year = v_card.cardname.left_name.right
    company = v_card.cardname.left_name.left_name.right
    metric = v_card.cardname.left_name.left_name.left
    values[year][company][metric] = v_card.content
  end
  values
end

def fetch_values_for_company company
  metrics = extract_metrics.unshift 'IN'
  values = Hash.new { |h, k| h[k] = {} }
  value_cards = Card.search right: 'value',
                            left: {
                              left:  {
                                right: company,
                                left: { name: metrics }
                              },
                              right: { type: 'year' }
                            }
  value_cards.each do |v_card|
    year = v_card.cardname.left_name.right
    metric = v_card.cardname.left_name.left_name.left
    values[year][metric] = v_card.content
  end
  values
end
