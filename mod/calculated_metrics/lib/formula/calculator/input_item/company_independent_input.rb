module Formula
  class Calculator
    class InputItem
      # Instances of {YearlyVariable} represent input items that refer to a yearly
      # variable
      # It uses the cards table to find values.
      # TODO: support year and company options
      module CompanyIndependentInput
        def value_store_class
          YearlyValueStore
        end

        def after_full_search
          answer_candidates.update nil, years_with_values, mandatory?
        end

        def mandatory?
          false # don't use this input to reduce company search space
        end

        def store_value company_id, year, value
          # We skip the companies_with_values update here.
          # In principle, we have to add all existing companies here for the
          # case that the formula has only company independent input items.
          # That seems too unlikely to justify this horrible slow move.
          value_store.add company_id, year, value
        end
      end
    end
  end
end
