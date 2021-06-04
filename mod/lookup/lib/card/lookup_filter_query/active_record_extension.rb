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

      def valid_page_args? args
        args.present? && args[:limit].to_i.positive?
      end
    end
  end
end
