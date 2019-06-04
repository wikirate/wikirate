module Formula
  class Calculator
    class ResultSpace
      # SearchSpace for formulas where only one of the input items needs to have a value.
      # Answer candidates for each input are joined with the existing candidates.
      module JoinSlices
        def answer_candidates
          @answer_candidates ||= SearchSpace.new
        end

        def update slice, _mandatory
          @fresh = false
          join slice
        end

        def run_out_of_options?
          false
        end

        private

        def join slice
          slice.each_pair do |year, company_ids|
            self[year.to_i] ||= ::Set.new
            self[year.to_i] |= company_ids
            @company_ids |= company_ids
          end
        end
      end
    end
  end
end
