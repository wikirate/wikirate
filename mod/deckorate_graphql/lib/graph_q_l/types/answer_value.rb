module GraphQL
  module Types
    # AnswerValue for GraphQL
    class AnswerValue < BaseScalar
      # self.coerce_input takes a GraphQL input and converts it into a Ruby value
      def self.coerce_input(input_value, _context)
        case input_value
        when Float, Integer, BigDecimal, defined?(BigInt) && BigInt
          input_value
        when String
          input_value.include?(",") ? input_value.split(", ") : input_value
        else
          input_value
        end
      end

      # self.coerce_result takes the return value of a field and prepares it for the GraphQL response JSON
      def self.coerce_result ruby_value, _context
        return Integer(ruby_value) if integer?(ruby_value)
        return Float(ruby_value) if float?(ruby_value)
        return ruby_value.split(", ") if ruby_value.is_a?(String) && ruby_value.include?(",")
        ruby_value
      end

      def self.integer?(value)
        Integer(value) rescue false
      end

      def self.float?(value)
        Float(value) rescue false
      end
    end
  end
end
