module Formula
  class Calculator
    class SearchSpace
      # SearchSpace for formulas where all or at least one of the input items needs to
      # have a value.
      # Answer candidates for each input are intersected with the existing candidates.
      module AllSearchSpace
        def update company_ids, years
          intersect company_ids, years
        end

        def intersect! search_space
          intersect_companies search_space.company_ids unless search_space.no_company_restriction?
           intersect_years search_space.years unless search_space.no_year_restriction?
        end

        private

        def intersect_companies c_ids
          return unless c_ids

          c_ids = c_ids.to_set
          @company_ids = no_company_restriction? ? c_ids : (@company_ids & c_ids)
        end

        def intersect_years years
          return unless years

          years = years.to_set
          @years = no_year_restriction? ? years : (@years & years.to_set)
        end
      end
    end
  end
end
