# cache # of answers for metric
include_set Abstract::CachedCount

# recount number of answers for a given metric when a Metric Value card is
# created or deleted
recount_trigger :type, :metric_answer, on: [:create, :delete] do |changed_card|
  changed_card.metric_card.fetch trait: :metric_answer
end

# TODO: trigger recount from virtual answer batches
