module Formula
  class Calculator
    class InputValues
      # the #result method and methods that support it
      module Results
        private

        def result company, year
          company = company.card_id
          year = year.to_i

          values = fetch company: company, year: year
          yield values, company, year
        end

        def results_for_companies_and_years companies, years, &block
          each_year(years) do |year|
            each_company(companies) do |company_id|
              result company_id, year, &block
            end
          end
        end

        def results_for_years years, &block
          each_year(years) do |year|
            companies_with_value(year).each do |company_id|
              result company_id, year, &block
            end
          end
        end

        def results_for_companies companies, &block
          each_company(companies) do |company_id|
            years_with_values(company_id).each do |year|
              result company_id, year, &block
            end
          end
        end

        def all_results &block
          years_with_values.each do |year|
            companies_with_value(year).each do |company_id|
              result company_id, year, &block
            end
          end
        end

        def each_year years, &block
          Array.wrap(years).map(&:to_i).each(&block)
        end

        def each_company companies, &block
          Array.wrap(companies).map(&:to_i).each(&block)
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
