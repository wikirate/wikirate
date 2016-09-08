include_set Set::TypePlusRight::Metric::AllValues

def refresh_cache_completely
  result = {}
  item_cards(default_query: true).each do |value_card|
    metric_card = value_card.metric_card
    next unless metric_card
    metric = metric_card.id
    result[metric] = [] unless result.key?(metric)
    result[metric].push construct_a_row value_card
  end
  result.to_json
end

def get_key changed_card, from=:new
  Card[extract_name(changed_card, :metric, from)].id.to_s
end
