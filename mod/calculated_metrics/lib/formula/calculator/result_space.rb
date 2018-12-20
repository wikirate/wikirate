module Formula
  class Calculator
    # Keeps track of companies that have values for all input metrics which means
    # it's possible to calculate answers for them.
    # It's a Set of company ids for every year
    class ResultSpace < Hash
      attr_reader :answer_candidates

      def initialize no_mandatories
        super() do |h, k|
          h[k] = ::Set.new
        end
        @fresh = true
        @answer_candidates = SearchSpace.new
        @company_ids = ::Set.new

        if no_mandatories
          extend JoinSlices
        else
          extend IntersectSlices
        end
      end

      def fresh?
        @fresh
      end

      def years
        keys
      end

      def for_year year
        self[year].to_a
      end

      def add company_id, year
        self[year.to_i] ||= ::Set.new
        self[year.to_i] << company_id
      end

      def cleaned
        if @search_space.unrestricted?
          unrestricted_clean
        else
          restricted_clean
        end
      end

      # remove everything that's not an answer candidate
      def unrestricted_clean
        to_a.each.with_object({}) do |(year, companies_by_year), h|
          next unless @answer_candidates.applicable_year? year
          h[year] = @answer_candidates.applicable_companies companies_by_year
        end
      end

      # don't remove entries outside of the search space
      def restricted_clean
        to_a.each.with_object({}) do |(year, companies_by_year), h|
          if !@search_space.applicable_year?(year)
            h[year] = companies_by_year
          elsif @answer_candidates.applicable_year?(year)
            h[year] = (@answer_candidates.applicable_companies(companies_by_year) +
                      (companies_by_year - @search_space.company_ids))
          end
        end
      end
    end
  end
end
