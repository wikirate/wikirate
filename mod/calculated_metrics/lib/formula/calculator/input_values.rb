module Formula
  class Calculator
    # It finds all metric values and yearly values that are related to the
    # the metrics and yearly variables of a formula and prepares the values
    # for calculating the formula values
    # The key method is #each that iterates over all
    # company and year combination that could possible get a calculated value
    # and provides the input data for the calculation
    class InputValues
      attr_reader :input_cards,:result_space, :parser, :input_list, :result_cache

      delegate :no_mandatories?, :validate, to: :input_list

      # @param [Formula::Parser] parser
      def initialize parser
        @parser = parser
        @input_cards = parser.input_cards
        @result_cache = ResultCache.new
        @input_list = InputList.new @parser
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
        years_with_values.each do |year|
          companies_with_value(year).each do |company_id|
            result company_id, year, &block
          end
        end
      end

      def each_year_with_value company_id, &block
        years_with_values(company_id).each do |year|
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

      # @return input values to calculate values for the given company and year
      #   If year is present [
      #   If year is given it returns an array with one value for every input card,
      #   otherwise it returns an array with a hash for every input card. The hashes
      #   contain a value for every year.
      def fetch company:, year:
        company = Card.fetch_id(company) unless company.is_a? Integer

        search_values_for company_id: company, year: year

        catch(:cancel_calculation) do
          @input_list.map do |input_item|
            input_item.value_for company, year
          end
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

      private

      def years_with_values company_id=nil
        search_values_for company_id: company_id
        @result_cache.years
      end

      def companies_with_value year
        search_values_for year: year
        @result_cache.for_year year
      end

      def search_values_for company_id: nil, year: nil
        while_full_input_set_possible company_id, year do |input_item, result_space|
          input_item.search_value_for result_space, company_id: company_id, year: year
        end
      end

      def full_search
        search_values_for
      end

      def while_full_input_set_possible company_id=nil, year=nil
        @result_cache.track_search company_id, year, no_mandatories? do |result_space|
          # subtle but IMPORTANT:
          # The "sort" call puts all items without non_researched option in front.
          # This way the search space becomes restricted before we have to deal with input
          # items that have a default value for the whole company-year-space.
          @input_list.sort.each do |input_item|
            yield input_item, result_space
            # skip remaining input items if there are no candidates left that can have
            # values for all input items
            break if result_space.run_out_of_options?
          end
        end
      end
    end
  end
end
