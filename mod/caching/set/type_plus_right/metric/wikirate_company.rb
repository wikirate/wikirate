# cache # of companies with values for metric (=_left)
include_set Abstract::SearchCachedCount

def search args={}
  company_ids = unique_company_ids
  case args[:return]
  when :id
    company_ids
  when :count
    company_ids.count
  when :name
    company_ids.map { |id| Card.fetch_name id }
  else
    company_ids.map { |id| Card.fetch id }
  end
end

def unique_company_ids
  Answer.where(metric_id: left.id).pluck(:company_id).uniq
end

def wql_hash
  company_ids = unique_company_ids
  if company_ids.any?
    { id: [:in] + company_ids }
  else
    { id: -1 } # HACK: ensure no results
  end
end

# turn query caching off because wql_hash varies and fetch_query
# doesn't recognizes changes in wql_hash
def fetch_query args={}
  query(args.clone)
end

# recount number of companies for a given metric when a Metric Value card is
# created or deleted
recount_trigger :type, :metric_value, on: [:create, :delete] do |changed_card|
  changed_card.metric_card.fetch(trait: :wikirate_company)
end
