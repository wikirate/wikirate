module GraphQL
  module Types
    # DeckorateSearch module facilitates card and lookup searches
    module DeckorateSearch
      def card_search codename, limit, offset, is_card, filter
        cql = codename.card.format.filter_cql_class.new(filter).to_cql
        search_base = is_card ? object.card.fetch(codename) : ::Card
        cql[:limit] = limit
        cql[:offset] = offset
        cql[:type_id] = codename.card.id unless is_card
        search_base.search cql
      end

      def lookup_search codename, limit, offset, is_card, filter
        query_hash = is_card ? object.card.fetch(codename).query_hash.merge(filter) : filter
        codename.card.query_class.new(
          query_hash, {},
          limit: limit,
          offset: offset
        ).lookup_relation.all
      end
    end
  end
end

