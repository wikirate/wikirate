class Card
  class AnswerQuery
    # filters based on year and children of the answer card
    # (as opposed to metric and company)
    module AnswerFilters
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

      def updated_query value
        return unless (period = timeperiod value)

        filter :updated_at, Time.now - period, ">"
      end

      def year_query value
        if value.try(:to_sym) == :latest
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
        when Array # category filters. eg ["option1", "option2"]
          filter :value, value
        when Hash  # numeric range filters. eg { from: 20, to: 30 }
          numeric_range_query value
        else       # keyword matching filter. eg "carbon"
          filter_like :value, value
        end
      end

      def numeric_range_query value
        filter :numeric_value, value[:from], ">=" if value[:from].present?
        filter :numeric_value, value[:to], "<" if value[:to].present?
      end

      def source_query value
        restrict_by_wql :answer_id,
                        type_id: Card::MetricAnswerID,
                        right_plus: [Card::SourceID, { refer_to: value }]
      end


      def related_company_group_query value

      end

      private

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
