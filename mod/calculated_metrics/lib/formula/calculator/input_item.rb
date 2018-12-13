module Formula
  class Calculator
    # {InputItem} represents a nest in a formula.
    # For example "{{Jedi+friedliness|year: -1}}" in the formula
    # "{{Jedi+friedliness|year: -1}} + 10 / {{Jedi+deadliness}}"
    # #
    # It is responsible for finding all relevant values for that input item.
    # How this is handled depends on two things:
    # The cardtype of the input item (either a metric or a yearly variable)
    # and the nest options (year and/or company)
    # The differences between the cardtypes is handled by the two subclasses
    # {MetricInput} and {YearlyVariableInput}.
    # The logic for the nest options is in the modules {}CompanyOption} and {YearOption}

    # Note: The main difference between metrics and yearly variables is that
    # yearly variables are in general independent of the company of the answer we
    # want to calculate.
    # But this can change. A metric with a fixed company option is also company
    # independent where as a yearly variable with a related company option is company
    # dependent. That's why the company dependency is separated into the modules
    # {CompanyDependentInput} and {CompanyIndependentInput}
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

      def initialize_decorator; end

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

      def years_with_values
        value_store.years
      end

      def before_full_search
        @value_store = value_store_class.new
      end

      # Find answer for the given input card and cache the result.
      # If year is given look only for that year
      def full_search
        each_answer(&method(:store_value))
      end

      def value_store
        @value_store ||= value_store_class.new
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
