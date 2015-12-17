# cache # of sources on which values for metric (=_left) are based on
include Card::CachedCount


# recount no. of sources on metric
ensure_set { TypePlusRight::MetricValue::Source }
recount_trigger MetricValue::Source do |changed_card|
  changed_card.left.metric_card.fetch trait: :source
end
