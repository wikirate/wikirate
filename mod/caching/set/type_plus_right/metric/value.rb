# cache # of values for left metric
include_set Abstract::SearchCachedCount

def search args={}
  Answer.search args.merge(metric_id: left.id)
end

# needed for "found_by" wql searches that refer to search results
# of these cards
def wql_hash
  answer_ids = search return: :answer_id
  if answer_ids.any?
    { id: [:in] + answer_ids }
  else
    { id: -1 } # HACK: ensure no results
  end
end

# turn query caching off because wql_hash varies and fetch_query doesn't
# recognizes changes in wql_hash
def fetch_query args={}
  query(args.clone)
end

# recount number of answers for a given metric when a Metric Value card is
# created or deleted
recount_trigger :type, :metric_value, on: [:create, :delete] do |changed_card|
  changed_card.metric_card.fetch(trait: :value)
end
