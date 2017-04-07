class Card
  class Query
    module CachedCountSorting
      def sort_by_count_cached_count val
        count_join = CachedCountJoin.new self, val[:right]
        joins << count_join
        @mods[:sort_as] = "integer"
        @mods[:sort] = "#{count_join.to_alias}.value"
      end
    end
  end
end
