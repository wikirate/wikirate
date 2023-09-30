module GraphQL
  module Types
    # DeckorateSearch module facilitates card and lookup searches
    module DeckorateSearch
      def deckorate_card_search(codename, is_card, filter, sort_by: :name,
                                sort_dir: desc, limit: 10, offset: 0)
        cql = codename.card.format.filter_cql_class.new(filter).to_cql
        search_base = is_card ? object.card.fetch(codename) : ::Card
        cql[:limit] = limit
        cql[:offset] = offset
        cql[:type_id] = codename.card.id unless is_card
        cql[:sort_by] = sort_by
        cql[:dir] = sort_dir
        search_base.search cql
      end

      def lookup_search codename, is_card, filter, sort: {}, limit: 10, offset: 0
        query_hash =
          is_card ? object.card.fetch(codename).query_hash.merge(filter) : filter
        codename.card.query_class.new(
          query_hash, sort,
          limit: limit,
          offset: offset
        ).lookup_relation.all
      end
    end
  end
end
