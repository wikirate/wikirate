class Card
  class AnswerQuery
    # handle ordering
    module Sorting
      SORT_BY_CARDNAME = {
        metric_designer: :designer_id,
        metric_title: :title_id,
        company_name: :company_id
      }.freeze

      def sort_and_page
        relation = yield
        @sort_joins.uniq.each { |j| relation = relation.joins(j) }

        relation.sort(@sort_hash).paging(@paging_args)
      end

      def process_sort
        @sort_joins = []
        @sort_hash = @sort_args.each_with_object({}) do |(key, val), h|
          h[sort_by(key)] = val
        end
      end

      def sort_by sort_by
        if (id_field = SORT_BY_CARDNAME[sort_by])
          sort_by_join sort_by, id_field
        else
          sort_by == :value ? sort_by_value : sort_by
        end
      end

      def sort_by_value
        numeric_sort? ? :numeric_value : :value
      end

      def sort_by_join sort_by, id_field
        @sort_joins << :metric if sort_by.to_s.match?(/^metric/)
        @sort_joins << "JOIN cards as #{sort_by} on #{sort_by}.id = #{id_field}"
        "#{sort_by}.key"
      end

      def numeric_sort?
        single_metric? && (metric_card.numeric? || metric_card.relationship?)
      end
    end
  end
end
