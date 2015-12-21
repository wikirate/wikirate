# cache # of metrics with values for this company (=_left)
include Card::CachedCount

# recount metrics related to company whenever a value is created or deleted
recount_trigger Type::MetricValue, on: [:create, :delete] do |changed_card|
  if (company_name = changed_card.company_name)
    Card.fetch company_name.to_name.trait(:metric)
  end
end
