# cache all values in a json hash of the form
# company => [{ year => ..., value => ...}, ... ]

include Card::CachedCount

# recount # of values for a metric when ...

# ... a +value is changed
ensure_set { TypePlusRight::MetricValue::Value }
ensure_set { Type::MetricValue }

recount_trigger TypePlusRight::MetricValue::Value do |changed_card|
  changed_card.metric_card.fetch trait: :all_values
end

# ... a Metric Value (type) is renamed
recount_trigger Type::MetricValue, changed: :name, on: :update do |changed_card|
  changed_card.metric_card.fetch(trait: :all_values)
end

# get all metric values
def calculate_count
  result = {}
  item_cards(default_query: true).each do |value_card|
    company = value_card.company_card.id
    result[company] = [] unless result.key?(company)
    result[company].push year: value_card.year, value: value_card.value
  end
  result.to_json
end
