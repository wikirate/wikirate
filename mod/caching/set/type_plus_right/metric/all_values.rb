# cache all values in a json hash of the form
# company => [{ year => ..., value => ...}, ... ]
include Card::CachedCount

def cached_count
  cached_count_card.content
end


# recount # of values for a metric when ...

# ... a +value is changed
recount_trigger(TypePlusRight::MetricValue::Value) do |changed_card|
  changed_card.metric_card.fetch trait: :all_values
end

# ... a Metric Value (type) is renamed
recount_trigger Type::MetricValue, changed: :name, on: :update do |changed_card|
  changed_card.metric_card.fetch(trait: :all_values)
end

# recount if company name was changed
# ensure_set { Type::MetricCompany }
# recount_trigger Type::MetricCompany, changed: :name do |changed_card|
#   metrics = Card.search type_id: MetricID, right_plus: changed_card.name
#   metrics.map do |metric|
#     metric.fetch trait: :all_values
#   end
# end

# initialize cached count if new metric is created (necessary?)
recount_trigger Type::Metric, on: :create do |changed_card|
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
