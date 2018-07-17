class Card
  module Query
    # joins card query with cached count table
    class CachedCountJoin < Join
      def initialize cardquery, right
        validate_right right
        super(from: cardquery, from_field: "id",
              to: %w[counts counts_table left_id])
        @conditions << "counts_table.right_id = #{@right_id}"
      end

      def validate_right right
        raise Card::Error::BadQuery, "sort by cached_count: no right given" unless right
        unless (@right_id = Card.fetch_id right)
          raise Card::Error::BadQuery,
                "cached count for +#{right}: #{right} does not exist"
        end
      end
    end
  end
end
