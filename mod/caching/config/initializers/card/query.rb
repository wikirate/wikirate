# require_dependency "card"
require_relative "../../../lib/card/query/cached_count_sorting"

class Card
  class Query
    include CachedCountSorting
  end
end
