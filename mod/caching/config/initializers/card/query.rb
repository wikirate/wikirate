class Card
  module Query
    class CardQuery
      require "card/query/cached_count_sorting"

      include CachedCountSorting
    end
  end
end
