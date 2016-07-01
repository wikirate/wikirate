include_set Set::TypePlusRight::Metric::AllValues

def calculate_count changed_card=nil
  result = {}
  item_cards(default_query: true).each do |value_card|
    metric = value_card.metric_card.id
    result[metric] = [] unless result.key?(metric)
    result[metric].push year: value_card.year, value: value_card.value
  end
  result.to_json
end
