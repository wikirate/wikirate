# This set makes its card members virtual search cards that uses
# the answer lookup table to get the search result and caches the search count
# in the cache count table.
# You have to include it with a :target_type option.
# Valid values have an id and a name column in the lookup table like
# :metric, :company, :record, or :designer. :answer works too although it has
# no name column.

include_set Abstract::SearchCachedCount

def self.included host_class
  host_class.include_set Abstract::CachedCount
  host_class
end

# override this to restrict the Answer search result
def search_anchor
  raise "need search anchor method"
end

def recount
  Answer.search answer_query(:count)
end

def answer_query return_field
  query = search_anchor
  query[:uniq] = target_id_field unless target_type == :answer
  query[:return] = return_field
  query
end

def target_id_field
  "#{target_type}_id".to_sym
end

# needed for "found_by" wql searches that refer to search results
# of these cards
def wql_content
  { id: [:in] + target_ids.compact }
end

def skip_search?
  target_ids.empty?
end

def target_ids
  ::Answer.search(answer_query(target_id_field))
end

# turn query caching off because wql_content can change
def cache_query?
  false
end
