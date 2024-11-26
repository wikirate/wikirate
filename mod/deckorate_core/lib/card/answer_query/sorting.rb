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

      def sort_dir dir
        return dir unless dir&.to_sym == :default_value_sort_dir

        numeric_sort? ? :desc : :asc
      end

      def sort_by_value
        numeric_sort? ? :numeric_value : :value
      end

      def simple_sort_by sort_by
        sort_by == :value ? sort_by_value : sort_by
      end

      def numeric_sort?
        single_metric? && (metric_card.numeric? || metric_card.relation?)
      end
    end
  end
end
