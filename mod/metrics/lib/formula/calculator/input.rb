module Formula
  class Calculator
    # It finds all metric values and yearly values that are related to the
    # the metrics and yearly variables of a formula and prepares the values
    # for calculating the formula values
    # The key method is #each that iterates over all
    # company and year combination that could possible get a calculated value
    # and provides the input data for the calculation
    class Input
      attr_reader :input_values

      # @param [Array<Card>] input_cards all cards that are part of the formula
      # @param [Array<String] year_options for every input card a year option
      # @param [Proc] input_cast a block that is called for every input value
      def initialize input_cards, year_options, &input_cast
        @input_cast = input_cast
        initialize_input_values input_cards, year_options
      end

      delegate :type, :card_id, to: :input_values

      # @param [Hash] opts restrict input values
      # @option opts [String] :company only yield input for given company
      # @option opts [String] :year only yield input for given year
      def each opts={}
        company = opts[:company]
        company = Card.fetch_id(company) unless company.is_a? Integer
        year = opts[:year]&.to_i

        @input_values.each company_id: company, year: year do |values, company_id, year|
          next unless (input_values = validate_input(values))
          yield input_values, company_id, year
        end
      end

      def input_for company, year
        year = year.to_i
        values = @input_values.fetch company: company, year: year
        validate_input values
      end

      private

      def initialize_input_values input_cards, year_options
        @year_options_processor = YearOptionsProcessor.new year_options
        @input_values =
          if @year_options_processor.no_year_options
            InputValues.new input_cards
          else
            InputValuesWithYearOptions.new input_cards, @year_options_processor
          end
      end

      def validate_input input
        return if !input || !input.is_a?(Array)
        input.map do |val|
          return if val.blank?
          if val.is_a?(Array)
            val.map do |v|
              return if v.blank?
              @input_cast.call v
            end
          else
            @input_cast.call val
          end
        end
      end
    end
  end
end
