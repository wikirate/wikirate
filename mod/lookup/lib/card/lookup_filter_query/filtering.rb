class Card
  class LookupFilterQuery
    # shared filtering methods for FilterQuery classes built on lookup tables
    module Filtering
      def process_filters
        normalize_filter_args
        return if @empty_result
        @filter_args.each { |k, v| process_filter_option k, v if v.present? }
        @restrict_to_ids.each { |k, v| filter k, v }
      end

      def normalize_filter_args
        # override
      end

      def process_filter_option key, value
        if (method = filter_method key)
          send method, key, value
        else
          try "#{key}_query", value
        end
      end

      def filter_method key
        case key
        when *simple_filters
          :filter_exact_match
        when *card_id_filters
          :filter_card_id
        end
      end

      def filter_exact_match key, value
        filter key, value if value.present?
      end

      def filter_card_id key, value
        return unless (card_id = to_card_id value)

        filter card_id_map[key], card_id
      end

      def not_ids_query value
        add_condition "#{lookup_class.card_column} not in (?)", value.split(",")
      end

      def to_card_id value
        if value.is_a?(Array)
          value.map { |v| Card.fetch_id(v) }
        else
          Card.fetch_id(value)
        end
      end

      def restrict_to_ids col, ids
        ids = Array(ids)
        @empty_result ||= ids.empty?
        restrict_lookup_ids col, ids
      end

      def restrict_lookup_ids col, ids
        existing = @restrict_to_ids[col]
        @restrict_to_ids[col] = existing ? (existing & ids) : ids
      end

      def restrict_by_cql col, cql
        cql.reverse_merge! return: :id, limit: 0
        restrict_to_ids col, Card.search(cql)
      end

      def filter field, value, operator=nil
        condition = "#{filter_table field}.#{field} #{op_and_val operator, value}"
        add_condition condition, value
      end

      def filter_table _field
        lookup_table
      end

      def op_and_val op, val
        "#{db_operator op, val} #{db_value val}"
      end

      def add_condition condition, value
        @conditions << condition
        @values << value
      end

      def db_operator operator, value
        operator || (value.is_a?(Array) ? "IN" : "=")
      end

      def db_value value
        value.is_a?(Array) ? "(?)" : "?"
      end
    end
  end
end
