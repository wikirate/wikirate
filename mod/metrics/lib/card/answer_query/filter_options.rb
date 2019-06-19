class Card
  class AnswerQuery
    # filter field handling
    module FilterOptions
      SIMPLE_FILTERS = ::Set.new(%i[company_id metric_id latest numeric_value]).freeze
      LIKE_FILTERS = ::Set.new(%i[company_name metric_name]).freeze
      CARD_ID_FILTERS = ::Set.new(%i[metric_type research_policy]).freeze

      protected

      def filter key, value, operator=nil
        db_col = db_column key
        db_op = db_operator operator, value
        db_val = db_value value
        method = subject_column_map[key] ? :add_card_condition : :add_condition
        send method, "#{db_col} #{db_op} #{db_val}", value
      end

      def add_condition condition, value
        @conditions << condition
        @values << value
      end

      def add_card_condition condition, value
        @card_conditions << condition
        @card_values << value
      end

      def subject_column_map
        return {} unless @join
        @subject_map ||= %i[id name].each_with_object({}) do |fld, hash|
          hash["#{@subject}_#{fld}".to_sym] = fld
        end
      end

      def db_column key
        if (subject_column = subject_column_map[key])
          "#{@subject}.#{subject_column}"
        else
          "answers.#{key}"
        end
      end

      def db_operator operator, value
        operator || (value.is_a?(Array) ? "IN" : "=")
      end

      def db_value value
        value.is_a?(Array) ? "(?)" : "?"
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

      def like_key key


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
        SIMPLE_FILTERS
      end

      def like_filters
        LIKE_FILTERS
      end

      def card_id_filters
        CARD_ID_FILTERS
      end
    end
  end
end
