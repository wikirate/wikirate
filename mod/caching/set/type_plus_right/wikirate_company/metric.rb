# cache # of metrics with values for this company (=_left)
include Card::CachedCount

expired_cached_count_cards(
  set: Type::MetricValue, on: [:create,:delete]
) do |changed_card|
  (company = changed_card.company_card) && company.fetch(trait: :metric)
end
