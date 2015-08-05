include Card::CachedCount

ensure_set do
  TypePlusRight::MetricValue::Source
end

expired_cached_count_cards :set=>TypePlusRight::MetricValue::Source do |changed_card|
  changed_card.item_cards
end
