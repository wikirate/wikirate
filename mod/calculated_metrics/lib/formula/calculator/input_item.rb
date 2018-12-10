module Formula
  class Calculator
    class InputItem
      attr_reader :card_id, :input_values
      delegate :answer_candidates, to: :input_values

      def initialize input_values, input_index, mandatory
        @input_values = input_values
        @input_index = input_index
        @input_card = input_values.input_cards[input_index]
        @card_id = @input_card.id
        @mandatory = mandatory
        extend CompanyOption if company_option?
        extend YearOption if year_option?
        initialize_decorator
      end

      def initialize_decorator
      end

      # @param [Array<company_id>] company_id when given search only for answers for those
      #    companies
      # @param [Array<year>] year when given search only for answers for those years
      def search_value_for company_id:, year:
        with_restricted_search_space company_id, year, &method(:search_all_values)
      end

      def search_all_values
        before_full_search
        full_search
        after_full_search
      end

      def with_restricted_search_space company_id, year
        @search_space = SearchSpace.new company_id, year
        @search_space.merge! answer_candidates
        @restricted_search_space = true
        yield
      ensure
        @search_space = nil
        @restricted_search_space = false
      end

      def search_space
        @search_space ||= answer_candidates
      end

      def restricted_search_space?
        @restricted_search_space || answer_search_space.present?
      end

      def before_full_search
        #@companies_with_values = ::Set.new
        #@years_with_values = ::Set.new
      end

      # Find answer for the given input card and cache the result.
      # If year is given look only for that year
      def full_search
        each_answer(&method(:store_value))
      end

      def after_full_search
        answer_candidates.update @companies_with_values, @years_with_values, mandatory?
      end

      def value_store
        @value_store ||= ValueStore.new true
      end

      def value_for company_id, year
        value_store.get company_id, year
      end

      def year_option?
        year_option.present? && year_option != "0"
      end

      def company_option?
        company_option.present?
      end

      def year_option
        @year_option ||=
          normalize_year_option @input_values.year_options[@input_index]
      end

      def company_option
        @company_option ||=
          normalize_company_option @input_values.company_options[@input_index]
      end

      def store_value company_id, year, value
        value_store.add company_id, year, value
        @input_values.companies_with_values.add company_id, year
      end

      def values_by_year company
        value_store.get company
      end

      def normalize_year_option option
        return unless option.present?
        option.sub("year:", "").tr("?", "0").strip
      end

      def normalize_company_option option
        return unless option.present?
        option.sub("company:", "").strip
      end

      # mandatory means
      # if this input item doesn't have a value (for a company and a year)
      # then the calculated value doesn't get a value (for that company and year)
      def mandatory?
        @mandatory
      end
    end
  end
end
