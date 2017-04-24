# cache # of values for left metric
include_set Abstract::SearchCachedCount

def search args={}
  answer_rel = Answer.where(metric_id: left.id)
  case args[:return]
  when :id
    answer_rel.pluck(:answer_id)
  when :count
    answer_rel.count
  when :name
    answer_rel.pluck(:answer_id).map { |id| Card.fetch_name id }
  else
    answer_rel.pluck(:answer_id).map { |id| Card.fetch id }
  end
end

# needed for "found_by" wql searches that refer to search results
# of these cards
def wql_hash
  answer_ids = Answer.where(metric_id: left.id).pluck(:answer_id)
  if metric_ids.any?
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
