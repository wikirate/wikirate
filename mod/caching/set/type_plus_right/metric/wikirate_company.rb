# cache # of companies with values for metric (=_left)
include_set Abstract::SearchCachedCount

def search args={}
  Answer.search metric_id: left.id, uniq: :company_id,
                return: companyify_return_arg(args[:return])
end

def companyify_return_arg val
  case val
  when :id, :company_id     then :company_id
  when :count               then :count
  when :name, :company_name then :company_name
  else                           :company_card
  end
end

# needed for "found_by" wql searches that refer to search results
# of these cards
def wql_hash
  company_ids = search return: :company_id
  if company_ids.any?
    { id: [:in] + company_ids }
  else
    { id: -1 } # HACK: ensure no results
  end
end

def wql_hash
  company_ids = search return: :company_id
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
