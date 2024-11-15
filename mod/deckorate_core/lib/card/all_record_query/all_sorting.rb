class Card
  class AllRecordQuery
    # handles "record" sorting in the cards table for AllRecordQuery searches
    module AllSorting
      private

      def sort_and_page
        rel = yield
        rel = sort rel
        rel = rel.limit @paging_args[:limit] if @paging_args[:limit]
        rel = rel.offset @paging_args[:offset] if @paging_args[:offset]
        rel
      end

      def sort rel
        @sort_hash.each do |fld, dir|
          rel, fld = interpret_sort_field rel, fld
          rel = rel.order Arel.sql("#{fld} #{dir}")
        end
        rel
      end

      def interpret_sort_field rel, fld
        case fld
        when /bookmarkers$/
          sort_by_bookmarkers rel
        when :metric_title, :metric_designer
          sort_by_metric_field rel, fld
        else
          [rel, fld]
        end
      end

      def sort_by sort_by
        if (partner_field = partner_field_map[sort_by])
          "#{partner}.#{partner_field}"
        else
          sort_by
        end
      end

      def sort_by_bookmarkers rel
        [Card::Bookmark.add_sort_join(rel, "#{partner}.id"), "cts.value"]
      end

      def sort_by_metric_field rel, field
        rel = join_metrics_table rel unless @mjoined
        @mjoined = true
        [rel.joins(metric_sort_join(field)), "sort.key"]
      end

      def metric_sort_join field
        field = RecordQuery::Sorting::SORT_BY_CARDNAME[field] || field
        "LEFT JOIN cards sort ON metrics.#{field} = sort.id"
      end

      def join_metrics_table rel
        rel.joins("JOIN metrics on metrics.metric_id = #{partner}.id")
      end

      def sort_join sql
        "LEFT JOIN cards sort ON #{partner}.#{sql}"
      end
    end
  end
end
