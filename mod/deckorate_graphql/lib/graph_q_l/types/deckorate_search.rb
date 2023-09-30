module GraphQL
  module Types
    # DeckorateSearch module facilitates card and lookup searches
    module DeckorateSearch
      def deckorate_card_search codename, options
        search_base = options[:is_card] ? object.card.fetch(codename) : ::Card
        search_base.search fetch_cql(codename, options)
      end

      def lookup_search codename, options
        query_hash = options[:filter]
        if options[:is_card]
          query_hash = object.card.fetch(codename).query_hash.merge(options[:filter])
        end
        codename.card.query_class.new(
          query_hash, options[:sort],
          limit: options[:limit],
          offset: options[:offset]
        ).lookup_relation.all
      end

      def fetch_cql codename, options
        cql = codename.card.format.filter_cql_class.new(options[:filter]).to_cql
        cql[:limit] = options[:limit]
        cql[:offset] = options[:offset]
        cql[:type_id] = codename.card.id unless options[:is_card]
        cql[:sort_by] = options[:sort_by]
        cql[:dir] = options[:sort_dir]
        cql
      end
    end
  end
end
