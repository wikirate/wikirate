class Card
  class AllAnswerQuery
    # handles "answer" sorting in the cards table for AllAnswerQuery searches
    module AllSorting
      private

      def process_sort
        super
        return unless (partner_field = partner_field_map[@sort_args[:sort_by]])

        @sort_args[:sort_by] = "#{@partner}.#{partner_field}"
      end

      def sort_and_page
        rel = yield
        rel = sort rel
        rel = rel.limit @paging_args[:limit] if @paging_args[:limit]
        rel = rel.offset @paging_args[:offset] if @paging_args[:offset]
        rel
      end

      def sort rel
        return rel unless @sort_args.present?
        case @sort_args[:sort_by].to_sym
        when :bookmarkers then sort_by_bookmarkers rel
        when :title_name then sort_by_metric_title rel
        else standard_sort rel
        end
      end

      def sort_by_bookmarkers rel
        Bookmark.sort rel, "#{@partner}.id", @sort_args[:sort_order]
      end

      def sort_by_metric_title rel
        rel.joins(sort_join("right_id = sort.id"))
           .order("sort.name #{@sort_args[:sort_order]}")
      end

      def standard_sort rel
        rel.order "#{@sort_args[:sort_by]} #{@sort_args[:sort_order]}"
      end

      def sort_join sql
        "LEFT JOIN cards sort ON #{@partner}.#{sql}"
      end
    end
  end
end
