module Formula
  class Calculator
    class InputValuesWithCompanyOptions < InputValues
      def fetch company:, year:
        values_for_all_years = super company: company, year: nil
        @input.year_options_processor.run values_for_all_years, year
      end

      private

      def answer_query input_card_id, _year
        # since we need the values for all years to handle the year options,
        # there is no point in restricting the query to one year
        super(input_card_id, nil)
      end

      def input_answers input_item, year
        return super unless input_item.company_option

        companies = input_item.company_option.companies_and_years


        @company_list.update answers.keys
        companies.map do |_subject_company_id, year, object_company_ids|
          query = { metric_id: input_item.card_id,
                    company_id: object_company_ids }
          query[:year] = year.to_i if year
          answer = Answer.fetch(query).compact

          @value_store.add
        end
      end
    end
  end
end
