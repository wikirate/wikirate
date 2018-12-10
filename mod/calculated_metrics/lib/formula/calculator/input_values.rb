module Formula
  class Calculator
    # It finds all metric values and yearly values that are related to the
    # the metrics and yearly variables of a formula and prepares the values
    # for calculating the formula values
    # The key method is #each that iterates over all
    # company and year combination that could possible get a calculated value
    # and provides the input data for the calculation
    class InputValues
      attr_reader :requirement, :input_cards, :company_options, :year_options,
                  :companies_with_values, :answer_candidates
      # @param [Input] an Input object
      # @param [Symbol] requirement either :all or :any
      def initialize formula_card
        @input_cards = formula_card.input_cards
        @requirement = formula_card.input_requirement
        @company_options = formula_card.company_options
        @year_options = formula_card.year_options

        @all_fetched = false

        @companies_with_values = CompaniesWithValues.new
        @input_list = InputList.new self
      end

      # Every iteration of the passed block receives an array with values for each
      # input item in the formula (= each double curly bracket part in the formula)
      # and a company_id and year which specifies
      # the answer that can be calculated with these input values.
      # The iteration can be restricted to a specific company or year or both.
      # @param company_id [Integer]
      # @param year [Integer]
      def each company_id: nil, year: nil, &block
        if company_id && year
          result company_id, year, &block
        elsif year
          each_company_with_value year, &block
        elsif company_id
          each_year_with_value company_id, &block
        else
          each_company_and_year_with_value(&block)
        end
      end

      def each_company_and_year_with_value &block
        full_search
        years_with_values.each do |year|
          companies_with_value(year).each do |company_id|
            result company_id, year, &block
          end
        end
      end

      def each_year_with_value company_id, &block
        years_with_values.each do |year|
          result company_id, year, &block
        end
      end

      def each_company_with_value year, &block
        companies_with_value(year).each do |company_id|
          result company_id, year, &block
        end
      end

      def result company_id, year
        values = fetch company: company_id, year: year
        yield values, company_id, year
      end

      # @return input values to calculate values for the given company
      #   If year is given it returns an array with one value for every input card,
      #   otherwise it returns an array with a hash for every input card. The hashes
      #   contain a value for every year.
      def fetch company:, year:
        company = Card.fetch_id(company) unless company.is_a? Integer

        search_values_for company_id: company, year: year

        @input_list.map do |input_item|
          input_item.value_for company, year
        end
      end

      # type of input
      # either :yearly_variable or, if it's a metric, the value type as string
      def type index
        @input_list[index].type
      end

      def card_id index
        @input_list[index].card_id
      end

      def all_input_required?
        @requirement == :all
      end

      private

      def years_with_values
        search_values
        @companies_with_values.years
      end

      def companies_with_value year
        search_values year: year
        @companies_with_values.for_year year
      end

      def search_values_for company_id: nil, year: nil
        full_search if company_id.nil? && year.nil?

        while_full_input_set_possible company_id, year do |input_item|
          input_item.search_value company_id: company_id, year: year
        end
      end

      def full_search
        return if @all_fetched
        @all_fetched = true

        while_full_input_set_possible(&:search_all_values)
        @companies_with_values.clean @company_list
      end

      def while_full_input_set_possible company_id=nil, year=nil
        @answer_candidates = SearchSpace.new company_id, year
        @input_list.each do |input_item|
          yield input_item
          # skip remaining input items if there are no candidates left then can have
          # values for all input items
          break if @answer_candidates.run_out_of_options?
        end
        @companies_with_values ||= CompaniesWithValues.new
      end
    end
  end
end
