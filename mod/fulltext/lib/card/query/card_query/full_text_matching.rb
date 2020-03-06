
Card::Query::ATTRIBUTES[:fulltext_match] = :relational

class Card
  module Query
    class CardQuery
      module FullTextMatching
        def fulltext_match value
          add_condition "MATCH (search_content) AGAINST (#{quote value})"
        end
      end
    end

    class SqlStatement
      module FullTextOrdering
        def order
          return if order_config == "relevance"
          super
        end
      end
      include FullTextOrdering
    end
  end
end
