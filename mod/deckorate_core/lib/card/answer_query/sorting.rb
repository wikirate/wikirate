class Card
  class AnswerQuery
    # handle ordering
    module Sorting
      SORT_BY_CARDNAME = {
        metric_designer: :designer_id,
        metric_title: :title_id,
        company_name: :company_id
      }.freeze

      def sort_by_cardname_join sort_by, _from_table, from_id_field
        return super unless sort_by.to_s.match?(/^metric/)

        @sort_joins << :metric
        super sort_by, :metrics, from_id_field
      end

      def sort_by_cardname
        SORT_BY_CARDNAME
      end
    end
  end
end
