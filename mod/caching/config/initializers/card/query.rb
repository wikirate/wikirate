class Card
  class Query
    require_dependency "card/query/cached_count_sorting"

    include CachedCountSorting
  end
end
