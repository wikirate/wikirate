include_set Set::TypePlusRight::Metric::AllValues

def refresh_cache_completely
  result = {}
  item_cards(default_query: true).each do |value_card|
    metric = value_card.metric_card.id
    result[metric] = [] unless result.key?(metric)
    result[metric].push construct_a_row value_card
  end
  result.to_json
end

def company_id changed_card, from=:new
  Card[extract_name(changed_card, :metric, from)].id.to_s
end

def construct_a_row value_card
  { year: value_card.year, value: value_card.value,
    last_update_time: value_card.updated_at.to_i }
end
