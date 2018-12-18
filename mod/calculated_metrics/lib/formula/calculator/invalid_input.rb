module Formula
  class Calculator
    # Placeholder for the case that formula contains input items that don't exist
    class InvalidInput
      def initialize; end

      def each opts={}; end

      def input_for company, year; end
    end
  end
end
