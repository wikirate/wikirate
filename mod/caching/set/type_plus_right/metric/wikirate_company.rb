# cache # of companies with values for left metric
include Card::CachedCount

ensure_set { Type::MetricValue }

# recount number of companies for a given metric when a Metric Value card is
# created or deleted
recount_trigger Type::MetricValue, on: [:create, :delete] do |changed_card|
  [
    changed_card.metric_card.fetch(trait: :wikirate_company),
    # metric + company name contains the latest year for the metric value set
    changed_card.left
  ]
end
