# cache all values in a json hash of the form
# company => [{ year => ..., value => ...}, ... ]
include Card::CachedCount

def cached_count
  cached_count_card.content
end

# expire if value was touched
expired_cached_count_cards(
  set: TypePlusRight::MetricValue::Value
) do |changed_card|
  changed_card.metric_card.fetch(trait: :all_values)
end

# expire if name was changed (that includes for example a year change)
expired_cached_count_cards set: Type::MetricValue,
                           changed: :name do |changed_card|
  changed_card.metric_card.fetch(trait: :all_values)
end

# expire if company name was changed
ensure_set { Type::MetricCompany }
expired_cached_count_cards set: Type::MetricCompany,
                           changed: :name do |changed_card|
  metrics = Card.search type_id: MetricID, right_plus: changed_card.name
  metrics.map do |metric|
    metric.fetch trait: :all_values
  end
end

# initialize cached values hash if new metric is created
expired_cached_count_cards set: Type::Metric, on: :create do |changed_card|
  changed_card.fetch trait: :all_values
end

# get all metric values
def calculate_count
  result = {}
  item_cards(default_query: true).each do |value_card|
    company = value_card.company
    result[company] = [] unless result.key?(company)
    result[company].push year: value_card.year, value: value_card.value
  end
  result.to_json
end
