class Calculate
  class Calculator
    class Input
      # methods for retrieving input answers
      module Answers
        private

        # @return Array[String] simple input values for the given company and year
        def fetch_answer company_id, year
          return unless @result_cache.has_value? company_id, year

          catch :cancel_calculation do
            @input_list.map { |input_item| input_item.answer_for company_id, year }
          end
        end

        def yield_answer company_id, year
          yield fetch_answer(company_id, year), company_id, year
        end

        def values_for_companies_and_years companies, years, &block
          each_year(years) do |year|
            each_company(companies) do |company_id|
              search_values_for company_id: company_id, year: year
              yield_answer company_id, year, &block
            end
          end
        end

        def values_for_years years, &block
          each_year(years) do |year|
            companies_with_value(year).each do |company_id|
              yield_answer company_id, year, &block
            end
          end
        end

        def values_for_companies companies, &block
          each_company(companies) do |company_id|
            years_with_values(company_id).each do |year|
              yield_answer company_id, year, &block
            end
          end
        end

        def all_values &block
          years_with_values.each do |year|
            companies_with_value(year).each do |company_id|
              yield_answer company_id, year, &block
            end
          end
        end

        def years_with_values company_id=nil
          search_values_for company_id: company_id
          @result_cache.years
        end

        def companies_with_value year
          search_values_for year: year
          @result_cache.for_year year
        end
      end
    end
  end
end
