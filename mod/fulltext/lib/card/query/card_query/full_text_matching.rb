
class Card
  module Query
    ATTRIBUTES[:fulltext_match] = :relational

    class CardQuery
      # handle `fulltext_match` condition in card queries
      module FullTextMatching
        def fulltext_match value
          add_condition "MATCH (#{table_alias}.search_content, #{table_alias}.name) " \
                        "AGAINST (#{quote value})"
        end
      end
    end

    class SqlStatement
      # handle `fulltext_match` relevance sorting in card queries
      module FullTextOrdering
        # when there is full text matching in the where clause,
        # the default ordering is by relevance, so we just need to
        # make sure there is no explicit order by clause
        def order
          return if order_config == "relevance"
          super
        end

        # Note: the alternative route

      end
      include FullTextOrdering
    end
  end
end
