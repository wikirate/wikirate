class Calculate
  class Calculator
    class InputItem
      # To be included if the values of the input item depends on the output company.
      # (ie, independent company is not specified for item)
      module CompanyDependentInput
        def value_store_class
          ValueStore
        end

        def companies_with_values
          value_store.companies
        end

        def company_dependent?
          true
        end

        def update_result_slice company_id, year, _value
          @result_slice.add company_id, year
        end
      end
    end
  end
end
