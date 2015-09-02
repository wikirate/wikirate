include Card::CachedCount

ensure_set do
  Type::MetricValue
end

expired_cached_count_cards :set=>Type::MetricValue, :on=>[:create,:delete] do |changed_card|
  [
    changed_card.metric_card.fetch(:trait=>:wikirate_company)
  ]
end

