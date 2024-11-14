class Card
  class RecordQuery
    # filters based on answer values
    module ValueFilters
      # :exists/researched (known + unknown) is default case;
      # :all and :none are handled in AllQuery
      def filter_by_status value
        case value.to_sym
        when :unknown
          filter :value, "Unknown"
        when :known
          filter :value, "Unknown", "<>"
        end
      end

      def filter_by_value value
        case value
        when Array # category filters. eg ["option1", "option2"]
          value_query_category value
        when Hash  # numeric range filters. eg { from: 20, to: 30 }
          value_query_numeric value
        else       # keyword matching filter. eg "carbon"
          filter :value, "%#{value.strip}%", "LIKE"
        end
      end

      private

      def value_query_category array
        if metric_card&.multi_categorical?
          value_query_multi_category array
        else
          filter :value, array
        end
      end

      def value_query_multi_category array
        # FIND_IN_SET only works with comma separation (no spaces).
        # So we have to use REPLACE to transform the category into what is expected
        constraints = array.map do |val|
          condition_sql ["FIND_IN_SET(?, REPLACE(answers.value, ', ', ','))", val]
        end
        @conditions << "(#{constraints.join ' OR '})"
      end

      def value_query_numeric value
        filter :numeric_value, value[:from], ">=" if value[:from].present?
        filter :numeric_value, value[:to], "<" if value[:to].present?
      end
    end
  end
end
