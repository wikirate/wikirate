# This set makes its card members virtual search cards that uses
# the answer lookup table to get the search result and caches the search count
# in the cache count table.
# You have to include it with a :target_type option.
# Valid values have an id and a name column in the lookup table like
# :metric, :company, :record, or :designer. :answer works too although it has
# no name column.

include_set Abstract::WqlSearch

def self.included host_class
  host_class.include_set Abstract::CachedCount
  host_class
end

def virtual?
  true
end

def type_id
  SearchTypeID
end

# override this to restrict the search result
def search_anchor
  {}
end

def search args={}
  return [] unless (anchor = search_anchor)
  Answer.search anchor.merge(uniq: target_id, return: return_arg(args[:return]))
end

def target_id
  "#{target_type}_id".to_sym
end

def target_name
  "#{target_type}_name".to_sym
end

def return_arg val
  case val
  when :id, target_id     then target_id
  when :count             then :count
  when :name, target_name then target_name
  else                         "#{target_type}_card"
  end
end

# needed for "found_by" wql searches that refer to search results
# of these cards
def wql_hash
  ids = search return: :id
  if ids.any?
    { id: [:in] + ids }
  else
    { id: -1 } # HACK: ensure no results
  end
end

# turn query caching off because wql_hash varies and fetch_query
# doesn't recognizes changes in wql_hash
def fetch_query args={}
  query(args.clone)
end
