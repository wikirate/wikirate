module Formula
  class Calculator
    class InputItem
      # Instances of {YearlyVariable} represent input items that refer to a yearly
      # variable
      # It uses the cards table to find values.
      # TODO: support year and company options
      module CompanyDependentInput
        def value_store_class
          ValueStore
        end

        def companies_with_values
          value_store.companies
        end

        def after_full_search
          answer_candidates.update companies_with_values, years_with_values, mandatory?
        end

        def store_value company_id, year, value
          value_store.add company_id, year, value
          @input_values.companies_with_values.add company_id, year
        end
      end
    end
  end
end
