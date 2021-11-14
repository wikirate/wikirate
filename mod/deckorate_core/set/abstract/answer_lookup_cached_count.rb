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
  ::Answer.search :count, answer_query
end

def answer_query
  query = search_anchor
  query[:uniq] = target_id_field unless target_type == :answer
  query
end

def target_id_field
  "#{target_type}_id".to_sym
end

# needed for "found_by" cql searches that refer to search results
# of these cards
def cql_content
  { id: [:in] + target_ids.compact }
end

def skip_search?
  target_ids.empty?
end

def target_ids
  ::Answer.search target_id_field, answer_query
end

# turn query caching off because cql_content can change
def cache_query?
  false
end
