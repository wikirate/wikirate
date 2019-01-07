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

      def remove company_id, year
        return unless self[year.to_i].present?

        self[year.to_i].delete company_id
        delete year.to_i if self[year.to_i].empty?
      end
    end
  end
end
