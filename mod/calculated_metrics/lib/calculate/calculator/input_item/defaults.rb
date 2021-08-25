class Calculate
  class Calculator
    class InputItem
      # Methods for override
      # (if they are defined directly on the base class, they can't be overridden)
      module Defaults
        def years_with_values
          value_store.years
        end

        def translate_years years
          years
        end

        def apply_year_option year_value_hash, year
          year_value_hash[year]
        end

        def year_value_pairs_by_company
          {}.tap do |hash|
            each_input_answer answers do |input_answer|
              company_hash = hash[input_answer.company_id] ||= {}
              company_hash[input_answer.year] = input_answer
            end
          end
        end

        def restrict_years_in_query?
          search_space.years?
        end

        def answer_query
          query = { metric_id: card_id }
          query[:year] = search_space.years if restrict_years_in_query?
          query[:company_id] = search_space.company_ids if search_space.company_ids?
          query
        end

        # overwritten in other places to move input items with no restriction on
        # companies or years (because of company and/or year options) to the end.
        # That way when they are processed the search
        # space for values is already restricted to some companies and years
        def sort_index
          @input_index
        end

        # mandatory means
        # if this input item doesn't have a value (for a company and a year)
        # then the calculated value doesn't get a value (for that company and year)
        # This can be changed with the not_researched nest option
        def mandatory?
          true
        end
      end
    end
  end
end
