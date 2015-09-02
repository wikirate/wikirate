include Card::CachedCount

ensure_set do
  Type::MetricValue
end

expired_cached_count_cards :set=>Type::MetricValue, :on=>[:create,:delete] do |changed_card|
  [
    changed_card.metric_card.fetch(:trait=>:wikirate_company),
    # actually this is not getting cached count for `metric+company` card
    # it is to refresh the related metric value to the company
    # refer to ltype_rtype/metric/wikirate_company.rb
    Card.fetch("#{changed_card.metric_name}+#{changed_card.company_name}")
  ]
end

