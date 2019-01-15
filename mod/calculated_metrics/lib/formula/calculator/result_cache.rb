module Formula
  class Calculator
    # Keeps track of companies that have values for all input metrics which means
    # it's possible to calculate answers for them.
    # It's a Set of company ids for every year
    class ResultCache < Hash
      def initialize
        @search_log = SearchLog.new
        super do |h, k|
          h[k] = ::Set.new
        end
      end

      def track_search company_id, year, no_mandatories
        return if @search_log.searched? company_id: company_id, year: year
        @search_space = SearchSpace.new company_id, year
        @result_space = ResultSpace.new no_mandatories
        yield @result_space
        merge @result_space
        @search_log.update @search_space
      end

      def has_value? company_id, year
        self[year.to_i].include? company_id
      end

      def years
        keys
      end

      def for_year year
        self[year].to_a
      end

      private

      def merge result_space
        result_space.each_pair do |year, company_ids|
          next if company_ids == :all
          self[year] ||= ::Set.new
          self[year] |= company_ids
        end
      end
    end
  end
end
