class Card
  class AnswerQuery
    # Query answers for a given metric
    class FixedMetric < AnswerQuery
      FILTER_TRANSLATIONS = { name: :company_name, wikirate_company: :company_name }

      def initialize metric_id, filter, sorting={}, paging={}
        @metric = Card[metric_id]
        filter[:metric_id] = metric_id
        prepare_metric_sorting sorting
        super filter, sorting, paging
      end

      def new_name company
        "#{@metric.name}+#{company}+#{new_name_year}"
      end

      def subject
        :company
      end

      def subject_type_id
        Card::WikirateCompanyID
      end

      def project_query value
        restrict_by_wql :company_id,
                        referred_to_by: "#{value}+#{:wikirate_company.cardname}"
      end

      private

      def prepare_metric_sorting sort
        return unless sort[:sort_by]&.to_sym == :value
        sort[:sort_by] = :numeric_value if @metric.numeric? || @metric.relationship?
      end
    end
  end
end
