class Card
  class LookupFilterQuery
    # support methods for sort and page
    module ActiveRecordExtension
      # @params hash [Hash] key1: dir1, key2: dir2
      def sort hash
        hash.present? ? sort_by_hash(hash) : self
      end

      def paging args
        return self unless valid_page_args? args
        limit(args[:limit]).offset(args[:offset])
      end

      private

      def valid_page_args? args
        args.present? && args[:limit].to_i.positive?
      end

      def sort_by_hash hash
        rel = self
        hash.each do |fld, dir|
          rel, fld = interpret_sort_field rel, fld
          rel = rel.order Arel.sql("#{fld} #{dir}")
        end
        rel
      end

      def interpret_sort_field rel, fld
        if (match = fld.match(/^(\w+)_bookmarkers$/))
          sort_by_bookmarkers match[1], rel
        else
          [rel, fld]
        end
      end

      def sort_by_bookmarkers type, rel
        [Card::Bookmark.add_sort_join(rel, "#{table.name}.#{type}_id"), "cts.value"]
      end
    end
  end
end
