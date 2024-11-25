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
def query_hash
  raise "need #query_hash method"
end

def count
  answer_query.count
end

def answer_query
  AnswerQuery.new(query_hash).lookup_relation.select(target_id_field).distinct
end

def target_id_field
  "#{target_type}_id".to_sym
end

# needed for "found_by" cql searches that refer to search results
# of these cards
def cql_content
  { id: answer_query }
end
