module Formula
  class Calculator
    class InputItem
      # To be included if the values of the input item depend on the output company.
      # Can be either a metric or a yearly variable with related company option.
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
