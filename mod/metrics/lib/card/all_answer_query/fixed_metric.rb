class Card
  class AllAnswerQuery
    # Query researched and not-researched answers for a given metric
    class FixedMetric < AllAnswerQuery
      def base_key
        :metric_id
      end

      def subject_key
        :company_id
      end

      def subject_type_id
        WikirateCompanyID
      end

      def filter_wql
        return {} unless @filter.present?
        CompanyFilterQuery.new(@filter).to_wql
      end

      def sort_company_name_wql
        :name
      end

      def new_name subject
        subject = Card.fetch_name(subject) if subject.is_a? Integer
        "#{@base_card.name}+#{subject}+#{new_name_year}"
      end
    end
  end
end
