module Formula
  class Calculator
    # It finds all answer values and yearly values that are related to the
    # the metrics and yearly variables of a formula and prepares the values
    # for calculating the formula values
    # The key method is #each that iterates over all
    # company and year combination that could possible get a calculated value
    # and provides the input data for the calculation
    class Input
      attr_reader :input_values

      # @param [Card] parser has to respond to #input_cards and #input_requirement
      # @param [Proc] input_cast a block that is called for every input value
      def initialize parser, &input_cast
        @input_cast = input_cast
        @input_values = InputValues.new parser
      end

      delegate :type, :card_id, to: :input_values

      # @param :companies [Array of Integers] only yield input for given companies
      # @option :years [Array of Integers] :year only yield input for given years
      def each companies: [], years: []
        @input_values.each companies: companies, years: years do |vals, company_id, year|
          next unless (input_values = normalize_values vals)
          yield input_values, company_id, year
        end
      end

      def input_for company, year
        values = @input_values.fetch company: company.card_id, year: year.to_i
        normalize_values values
      end

      def answers company: nil, year: nil
        @input_values.answers company&.card_id, year&.to_i
      end

      private

      def validate_input input
        return unless input.is_a? Array
        input.map! { |v| normalize_values v }
        return unless requirements_satisfied? input
        input
      end

      def requirements_satisfied? input
        case @requirement
        when :all
          !input.any?(&:blank?)
        when :any
          input.flatten.compact.present?
        else
          true
        end
      end

      def normalize_values val
        case val
        when Symbol
          val
        when Array
          val.map(&method(:normalize_values))
        else
          val.blank? ? nil : @input_cast.call(val)
        end
      end
    end
  end
end
