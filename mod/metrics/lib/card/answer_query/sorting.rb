class Card
  class AnswerQuery
    # handle ordering
    module Sorting
      SORT_JOIN_FIELD = {
        metric_designer: :designer_id,
        metric_title: :title_id,
        company_name: :company_id
      }.freeze

      def sort_and_page
        relation = yield
        @sort_joins.each { |j| relation = relation.joins(j) }

        relation.sort(@sort_hash).paging(@paging_args)
      end

      def process_sort
        @sort_joins = []
        sort_bys = Array.wrap(@sort_args[:sort_by]).compact
        sort_dirs = Array.wrap(@sort_args[:sort_dir]).compact
        @sort_hash = sort_bys.each_with_index.with_object({}) do |(by, i), h|
          h[sort_by(by.to_sym)] = sort_dirs[i]
        end
      end

      def sort_by sort_by
        if (id_field = SORT_JOIN_FIELD[sort_by])
          sort_by_join sort_by, id_field
        else
          sort_by == :value ? sort_by_value : sort_by
        end
      end

      def sort_by_value
        numeric_sort? ? :numeric_value : :value
      end

      def sort_by_join sort_by, id_field
        @sort_joins << "JOIN cards as #{sort_by} on #{sort_by}.id = #{id_field}"
        "#{sort_by}.key"
      end

      def numeric_sort?
        single_metric? && (metric_card.numeric? || metric_card.relationship?)
      end
    end
  end
end
