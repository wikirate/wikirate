class Card
  class AnswerQuery
    # conditions and condition support methods for non-standard fields.
    module FieldConditions
      def restrict_to_ids col, ids
        ids = Array(ids)
        @empty_result = ids.empty?
        if restrict_cards? col
          restrict_card_ids ids
        else
          restrict_answer_ids col, ids
        end
      end

      def restrict_cards? col
        return false unless @join
        col == "#{@subject}_id".to_sym
      end

      def restrict_card_ids ids
        @card_ids += ids
      end

      def restrict_answer_ids col, ids
        @restrict_to_ids[col] ||= []
        @restrict_to_ids[col] += ids
      end

      def restrict_by_wql col, wql
        wql.reverse_merge! return: :id, limit: 0
        restrict_to_ids col, Card.search(wql)
      end

      # :exists/researched (known + unknown) is default case;
      # :all and :none are handled in #run
      def status_query value
        case value.to_sym
        when :unknown
          filter :value, "Unknown"
        when :known
          filter :value, "Unknown", "<>"
        end
      end

      def updated_query value
        return unless (period = timeperiod value)

        filter :updated_at, Time.now - period, ">"
      end

      def year_query value
        if value.to_sym == :latest
          filter :latest, true
        else
          filter :year, value.to_i
        end
      end

      def check_query value
        case value
        when "Completed" then filter :checkers, nil, "IS NOT"
        when "Requested" then filter :check_requester, nil, "IS NOT"
        when "Neither"
          %i[checkers check_requester].each { |fld| filter fld, nil, "IS" }
        end
      end

      def value_query value
        case value
        when Array then filter :value, value
        when Hash  then numeric_range_query value
        else            filter_like :value, value
        end
      end

      def numeric_range_query value
        filter :numeric_value, value[:from], ">=" if value[:from].present?
        filter :numeric_value, value[:to], "<" if value[:to].present?
      end

      def source_query value
        restrict_by_wql :answer_id,
                        type_id: MetricAnswerID,
                        right_plus: [SourceID, { refer_to: value }]
      end

      def industry_query value
        restrict_by_wql :company_id, CompanyFilterQuery.industry_wql(value)
      end

      def timeperiod value
        case value.to_sym
        when :today then
          1.day
        when :week then
          1.week
        when :month then
          1.month
        end
      end
    end
  end
end
