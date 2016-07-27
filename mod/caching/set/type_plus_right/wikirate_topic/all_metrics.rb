include Card::CachedCount

ensure_set { TypePlusRight::Metric::WikirateTopic }

recount_trigger TypePlusRight::Metric::WikirateTopic do |changed_card|
  names = Card::CachedCount.pointer_card_changed_card_names(changed_card)
  names.map do |topic_name|
    Card[topic_name].fetch(trait: :all_metrics)
  end
end

# get all related metrics
def calculate_count _changed_card=nil
  result = {}
  item_cards(default_query: true).each do |metric_card|
    metric = metric_card.id
    result[metric] = true unless result.key?(metric)
  end
  result.to_json
end
