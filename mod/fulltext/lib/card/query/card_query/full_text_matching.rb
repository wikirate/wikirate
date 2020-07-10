
class Card
  module Query
    ATTRIBUTES[:fulltext_match] = :relational

    class CardQuery
      # handle `fulltext_match` condition in card queries
      module FullTextMatching
        def fulltext_match value
          if value.strip.empty?
            nil
          elsif regexp_match? value
            match value
          else
            fulltext_match_condition value
          end
        end

        def fulltext_match_condition value
          add_condition "MATCH (#{table_alias}.search_content, #{table_alias}.name) " \
                        "AGAINST (#{quote value} #{fulltext_mode value})"
        end

        def fulltext_mode value
          return "IN BOOLEAN MODE" if value.gsub!(/^\:\:/, "")
          value.gsub!(/^\:\:/, "")
          ""
        end

        def regexp_match? value
          value.match?(/^\~/)
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

        # Note: the more explicit route (which will be necessary if we want to support
        # relevance as one of multiple sort options), is to do something like
        # select MATCH (x) AGAINST (y) as relevance... order by relevance desc
      end
      include FullTextOrdering
    end
  end
end
