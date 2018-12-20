module Formula
  class Calculator
    class SearchSpace
      # SearchSpace for formulas where only one of the input items needs to have a value.
      # Answer candidates for each input are joined with the existing candidates.
      module AnySearchSpace
        def update company_ids, years
          join company_ids, years
        end

        def run_out_of_options?
          false
        end

        def applicable_companies new_ids
          new_ids = new_ids.to_set
          return new_ids if no_company_restriction?

          new_ids | @company_ids
        end

        private

        def join company_ids, years
          join_companies company_ids
          join_years years
        end

        def join_companies c_ids
          return unless c_ids

          c_ids = c_ids.to_set
          @company_ids = no_company_restriction? ? c_ids : (@company_ids | c_ids)
        end

        def join_years years
          return unless years

          years = year.to_set
          @years = no_year_restriction? ? years : (@years | years)
        end
      end
    end
  end
end
