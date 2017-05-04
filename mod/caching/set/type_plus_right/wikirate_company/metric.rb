# cache # of metrics with answers for this company (=left)
include_set Abstract::SearchCachedCount

def search args={}
  retrn = case args[:return]
          when :id, :metric_id     then :metric_id
          when :count              then :count
          when :name, :metric_name then :metric_name
          else                          :metric_card
          end
  Answer.search company_id: left.id, uniq: :metric_id, return: retrn
end

# needed for "found_by" wql searches that refer to search results
# of these cards
def wql_hash
  metric_ids = search return: :metric_id
  if metric_ids.any?
    { id: [:in] + metric_ids }
  else
    { id: -1 } # HACK: ensure no results
  end
end

# turn query caching off because wql_hash varies and fetch_query
# doesn't recognizes changes in wql_hash
def fetch_query args={}
  query(args.clone)
end

# recount metrics related to company whenever a value is created or deleted
recount_trigger :type, :metric_value, on: [:create, :delete] do |changed_card|
  if (company_name = changed_card.company_name)
    Card.fetch company_name.to_name.trait(:metric)
  end
end
