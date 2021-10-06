class Calculate
  class Calculator
    # Placeholder for the case that formula contains input items that don't exist
    class InvalidInput
      def initialize; end

      def each _opts={}; end

      def input_for _company, _year; end

      def answers_for _company_id, _year
        []
      end
    end
  end
end
