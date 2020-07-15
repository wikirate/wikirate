
class Card
  module Query
    ATTRIBUTES[:fulltext_match] = :relational

    class CardQuery
      # handle `fulltext_match` condition in card queries
      module FullTextMatching
        def fulltext_match value
          return if value.strip.empty?
          if prefixed_match? value
            name_match value
          else
            add_condition Value.new([:match, ":#{value}"], self).to_sql(:name)
          end
        end

        def prefixed_match? value
          value.match?(/^[\~\:\=]/)
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
          super unless order_config == "relevance"
        end

        # Note: the more explicit route (which will be necessary if we want to support
        # relevance as one of multiple sort options), is to do something like
        # select MATCH (x) AGAINST (y) as relevance... order by relevance desc
      end
      include FullTextOrdering
    end

    class Value
      def self.match_prefices
        @match_prefices ||= %w[= ~ :]
      end

      module FullTextValue
        def match_sql _field
          return super unless fulltext_match_term?
          "MATCH (#{fulltext_fields}) AGAINST (#{quote match_term} #{fulltext_mode})"
        end

        def fulltext_match_term?
          match_prefix.match? ":"
        end

        def fulltext_fields
          %i[search_content name].map { |fld| "#{@query.table_alias}.#{fld}" }.join ", "
        end

        def fulltext_mode
          match_prefix == "::" ? "IN BOOLEAN MODE" : ""
        end
      end
      include FullTextValue
    end
  end
end
