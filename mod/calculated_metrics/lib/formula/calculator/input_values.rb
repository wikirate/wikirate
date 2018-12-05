module Formula
  class Calculator
    # It finds all metric values and yearly values that are related to the
    # the metrics and yearly variables of a formula and prepares the values
    # for calculating the formula values
    # The key method is #each that iterates over all
    # company and year combination that could possible get a calculated value
    # and provides the input data for the calculation
    class InputValues
      attr_reader :input, :value_store
      # @param [Input] an Input object
      # @param [Symbol] requirement either :all or :any
      def initialize input
        @input = input
        @requirement = input.requirement
        @all_fetched = false
        @companies_with_values_by_year = Hash.new_nested ::Set
        @input_list = InputList.new self
        @value_store = ValueStore.new @input_list
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
        fetch_values
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

      def fetch_all
        fetch_values
      end

      # @return input values to calculate values for the given company
      #   If year is given it returns an array with one value for every input card,
      #   otherwise it returns an array with a hash for every input card. The hashes
      #   contain a value for every year.
      def fetch company:, year:
        company = Card.fetch_id(company) unless company.is_a? Integer

        fetch_values company_id: company, year: year

        @input_list.map do |input_item|
          @value_store.get input_item.card_id, company, year
        end
      end

      def years_with_values
        fetch_values
        @companies_with_values_by_year.keys
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

      def companies_with_value year
        fetch_values year: year
        @companies_with_values_by_year[year].to_a
      end

      # all values by year for one single input card
      def values_by_year input_item, company
        value_store.get input_item.card_id, company
      end

      def fetch_values company_id: nil, year: nil
        return if @all_fetched
        @all_fetched ||= company_id.nil? && year.nil?

        while_full_input_set_possible company_id do |input_item|
          input_item.fetch_value year
        end
        clean_companies_with_value_by_year
      end

      def while_full_input_set_possible company_id=nil
        @company_list = CompanyList.new @requirement, company_id
        @input_list.each do |input_item|
          yield input_item
          # skip remaining input items if there are no candidates left then can have
          # values for all input items
          break if @company_list.run_out_of_options?
        end
        @companies_with_values_by_year ||= Hash.new_nested ::Set
      end

      # if a company definitely doesn't meet input requirements,
      # remove it completely
      def clean_companies_with_value_by_year
        @companies_with_values_by_year =
          @companies_with_values_by_year
          .to_a.each.with_object({}) do |(year, companies_by_year), h|
            h[year] = @company_list.applicable_companies companies_by_year
          end
      end

      def store_value input_item, company_id, year, value
        @value_store.add input_item.card_id, company_id, year, value
        @companies_with_values_by_year[year.to_i] ||= ::Set.new
        @companies_with_values_by_year[year.to_i] << company_id
      end

    end
  end
end
