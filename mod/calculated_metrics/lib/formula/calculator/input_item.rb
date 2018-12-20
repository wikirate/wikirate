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
    # The logic for the nest options is in the modules {CompanyOption} and {YearOption}

    # Note: The main difference between metrics and yearly variables is that
    # yearly variables are in general independent of the company of the answer we
    # want to calculate.
    # But this can change. A metric with a fixed company option is also company
    # independent whereas a yearly variable with a related company option is company
    # dependent. That's why the company dependency is separated into the modules
    # {CompanyDependentInput} and {CompanyIndependentInput}
    class InputItem
      include ValidationChecks
      include Options

      attr_reader :card_id, :input_list, :result_space
      delegate :answer_candidates, to: :result_space
      delegate :parser, to: :input_list

      def initialize input_list, input_index
        @input_list = input_list
        @input_index = input_index

        @input_card = parser.input_cards[input_index]
        @card_id = @input_card.id
        initialize_options
        # @value_store = value_store_class.new
      end

      # @param [Array<company_id>] company_id when given search only for answers for those
      #    companies
      # @param [Array<year>] year when given search only for answers for those years
      def search_value_for result_space, company_id:, year:
        return search result_space if company_id.nil? && year.nil?

        @result_space = result_space
        with_restricted_search_space company_id, year do
          search result_space
        end
      end

      def search result_space
        @result_space = result_space
        @result_slice = ResultSlice.new
        full_search
        after_search
      end

      def with_restricted_search_space company_id, year
        @search_space = SearchSpace.new company_id, year
        @search_space.intersect! result_space.answer_candidates
        yield
      ensure
        @search_space = nil
      end

      def search_space
        @search_space ||= result_space.answer_candidates
      end

      def years_with_values
        value_store.years
      end

      # Find answer for the given input card and cache the result.
      # If year is given look only for that year
      def full_search
        each_answer(&method(:store_value))
      end

      def after_search
        result_space.update @result_slice, mandatory?
      end

      def store_value company_id, year, value
        value_store.add company_id, year, value
        update_result_slice company_id, year
      end

      def value_store
        @value_store ||= value_store_class.new
      end

      # @return a hash { year => value } if year is nil otherwise only value.
      #   Value is usually a string, but it can be an array of strings if the input item
      #   uses an option that generates multiple values for one year like a
      #   year option "year: 2000..-1"
      def value_for company_id, year
        value_store.get company_id, year
      end

      def values_by_year company
        value_store.get company
      end

      def sort_index
        @input_index
      end

      def <=> other
        sort_index <=> other.sort_index
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
