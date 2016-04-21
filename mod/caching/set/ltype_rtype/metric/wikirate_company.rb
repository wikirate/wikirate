# cache year of latest metric value
include Card::CachedCount

ensure_set { TypePlusRight::MetricValue::Value }
recount_trigger TypePlusRight::MetricValue::Value, &:metric_plus_company_card

# returns year of latest metric value
def calculate_count
  (metric_value = search_latest_value_name) &&
    metric_value.to_name.right.to_i || 0
end

def search_latest_value_name
  Card.search(
    left: name,
    right: { type: 'year' },
    dir: 'desc',
    limit: 1,
    return: 'name'
  ).first
end
