class Card
  class AnswerQuery
    # filter field handling
    module FilterOptions
      protected

      def filter key, value, operator=nil
        db_col = db_column key
        db_op = db_operator operator, value
        db_val = d_value value
        @conditions << "answers.#{db_col} #{db_op} #{db_val}"
        @values << value
      end

      def db_column key
        self.class::DB_COLUMN_MAP[key] || key
      end

      def db_operator operator, value
        operator || (value.is_a? Array ? "IN" : "=")
      end

      def db_value value
        value.is_a? Array ? "(?)" : "?"
      end

      # TODO: optimize with hash lookups for methods
      def process_filter_option key, value
        %i[exact_match like card_id].each do |ftype|
          if send("#{ftype}_filters").include? key
            return send("filter_#{ftype}", key, value)
          end
        end
        try "#{key}_query", value
      end

      def filter_exact_match key, value
        return unless value.present?
        filter key, value
      end

      def filter_like key, value
        return unless value.present?
        if (m = value.match(/^['"]([^'"]+)['"]$/))
          filter key, m[1]
        else
          filter key, "%#{value}%", "LIKE"
        end
      end

      def filter_card_id key, value
        return unless (card_id = to_card_id value)

        filter key, card_id
      end

      def to_card_id value
        if value.is_a?(Array)
          value.map { |v| Card.fetch_id(v) }
        else
          Card.fetch_id(value)
        end
      end

      def exact_match_filters
        self.class::SIMPLE_FILTERS
      end

      def like_filters
        self.class::LIKE_FILTERS
      end

      def card_id_filters
        self.class::CARD_ID_FILTERS
      end
    end
  end
end
