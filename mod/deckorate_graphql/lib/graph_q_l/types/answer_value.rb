module GraphQL
  module Types
    # AnswerValue for GraphQL
    class AnswerValue < BaseScalar
      description "An answer value that can be either a string, an integer, a float or an array"

      # self.coerce_input takes a GraphQL input and converts it into a Ruby value
      def self.coerce_input(input_value, context)
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
      def self.coerce_result(ruby_value, context)
        if integer?(ruby_value)
          Integer(ruby_value)
        elsif float?(ruby_value)
          Float(ruby_value)
        elsif big_int?(ruby_value)
          BigInt(ruby_value)
        elsif big_decimal?(ruby_value)
          BigDecimal(ruby_value)
        elsif ruby_value.to_s.include?(",")
          ruby_value.split(", ")
        else
          ruby_value
        end
      end

      def self.integer?(value)
        Integer(value) rescue false
      end

      def self.float?(value)
        Float(value) rescue false
      end

      def self.big_int?(value)
        defined?(BigInt) && BigInt(value) rescue false
      end

      def self.big_decimal?(value)
        defined?(BigDecimal) && BigDecimal(value) rescue false
      end
    end
  end
end
