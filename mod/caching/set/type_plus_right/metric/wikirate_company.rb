include Card::CachedCount

ensure_set do
  Type::MetricValue
end

expired_cached_count_cards :set=>Type::MetricValue, :on=>[:create,:delete] do |changed_card|
  result = [
    # cache number of the metric values related to this metric value set
    # for some query
    changed_card.metric_card.fetch(:trait=>:wikirate_company)
  ]
  # it is to refresh the related metric value to the company
  # refer to ltype_rtype/metric/wikirate_company.rb
  if (metric_card = changed_card.metric_card) && 
      metric_card.type_id == MetricID &&
      (company_card = changed_card.company_card) &&
      company_card.type_id == WikirateCompanyID
    result.push(Card.fetch("#{metric_card.name}+#{company_card.name}"))
  end
  result
end

