 # cache year of latest metric value
include Card::CachedCount

ensure_set { TypePlusRight::MetricValue::Value }
recount_trigger TypePlusRight::MetricValue::Value, &:metric_plus_company_card

# ) do |changed_card|
#  changed_card.metric_plus_company_card
# end

# returns year of latest metric value
def calculate_count
  (metric_value = search_latest_value_name) && metric_value.to_name.right.to_i
end

def search_latest_value_name
  Card.search(left: name, right: { type: 'year' },
              dir: 'asc',
              limit: 1,
              return: 'name').first
end
