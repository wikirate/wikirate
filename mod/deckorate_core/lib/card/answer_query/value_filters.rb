class Card
  class AnswerQuery
    # filters based on answer values
    module ValueFilters
      # :exists/researched (known + unknown) is default case;
      # :all and :none are handled in AllQuery
      def status_query value
        case value.to_sym
        when :unknown
          filter :value, "Unknown"
        when :known
          filter :value, "Unknown", "<>"
        end
      end

      def value_query value
        case value
        when Array # category filters. eg ["option1", "option2"]
          category_query value
        when Hash  # numeric range filters. eg { from: 20, to: 30 }
          numeric_range_query value
        else       # keyword matching filter. eg "carbon"
          filter :value, "%#{value.strip}%", "LIKE"
        end
      end

      private

      def category_query array
        if metric_card&.multi_categorical?
          multi_category_query array
        else
          filter :value, array
        end
      end

      def multi_category_query array
        # FIND_IN_SET only works with comma separation (no spaces).
        # So we have to use REPLACE to transform the category into what is expected
        constraints = array.map do |val|
          condition_sql ["FIND_IN_SET(?, REPLACE(answers.value, ', ', ','))", val]
        end
        @conditions << "(#{constraints.join ' OR '})"
      end

      def numeric_range_query value
        filter :numeric_value, value[:from], ">=" if value[:from].present?
        filter :numeric_value, value[:to], "<" if value[:to].present?
      end
    end
  end
end
