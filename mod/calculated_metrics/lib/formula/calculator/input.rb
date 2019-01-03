module Formula
  class Calculator
    # It finds all metric values and yearly values that are related to the
    # the metrics and yearly variables of a formula and prepares the values
    # for calculating the formula values
    # The key method is #each that iterates over all
    # company and year combination that could possible get a calculated value
    # and provides the input data for the calculation
    class Input
      attr_reader :input_values, :input_cards

      # @param [Card] parser has to respond to #input_cards and #input_requirement
      # @param [Proc] input_cast a block that is called for every input value
      def initialize parser, &input_cast
        @input_cards = parser.input_cards
        @input_cast = input_cast
        @input_values = InputValues.new parser
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
          next unless (input_values = normalize_values(values))
          yield input_values, company_id, year
        end
      end

      def input_for company, year
        year = year.to_i
        values = @input_values.fetch company: company, year: year
        normalize_values values
      end

      private

      def validate_input input
        return unless input.is_a?(Array)
        input.map! do |val|
          val = normalize_values val
          return if @requirement == :all && val.blank?
          val
        end
        @requirement == :any && input.flatten.compact.blank? ? nil : input
      end

      def normalize_values val
        if val.is_a?(Symbol)
          val
        elsif val.is_a?(Array)
          val.map(&method(:normalize_values))
        elsif val.blank?
          nil
        else
          @input_cast.call(val)
        end
      end
    end
  end
end
