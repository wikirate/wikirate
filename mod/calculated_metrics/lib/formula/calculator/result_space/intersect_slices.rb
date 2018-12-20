module Formula
  class Calculator
    class ResultSpace
      # SearchSpace for formulas where all or at least one of the input items needs to
      # have a value.
      # Answer candidates for each input are intersected with the existing candidates.
      module IntersectSlices
        def update slice, mandatory
          return unless mandatory
          if fresh?
            @fresh = false
            replace slice
            @answer_candidates = SearchSpace.new slice.company_ids,years
          else
            intersect slice
          end
        end

        def run_out_of_options?
          return false if fresh?

          empty?
        end

        private

        def intersect result_slice
          @company_ids = ::Set.new
          slice!(*result_slice.years)
          each_key do |year|
            self[year] &= result_slice[year] unless result_slice[year] == :all
            @company_ids |= self[year]
          end
          delete_if { |_k, v| v.empty? }
          @answer_candidates = SearchSpace.new @company_ids, years
        end
      end
    end
  end
end
