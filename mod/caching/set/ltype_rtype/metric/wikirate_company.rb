# cache year of latest metric value
include_set Abstract::CachedCount

recount_trigger :type_plus_right, :metric_value, :value, &:metric_plus_company_card

# returns year of latest metric value
def recount
  (metric_value = search_latest_value_name) &&
    metric_value.to_name.right.to_i || 0
end

def search_latest_value_name
  Card.search(
    left: name,
    right: { type: "year" },
    dir: "desc",
    sort: "name",
    limit: 1,
    return: "name"
  ).first
end
