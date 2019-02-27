# cache # of answers for company
include_set Abstract::CachedCount

def recount
  Answer.where(company_id: left.id).count
end

def count
  cached_count
end

# recount number of answers for a given metric when a Metric Value card is
# created or deleted
recount_trigger :type, :metric_answer, on: [:create, :delete] do |changed_card|
  changed_card.company_card.fetch trait: :metric_answer
end

# TODO: trigger recount from virtual answer batches