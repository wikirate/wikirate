# cache # of sources on which values for metric (=_left) are based on
include Card::CachedCount

ensure_set { TypePlusRight::MetricValue::Source }
expired_cached_count_cards :set=>TypePlusRight::MetricValue::Source do |changed_card|
  changed_card.left.metric_card.fetch trait: :source
end
