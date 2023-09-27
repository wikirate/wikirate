module GraphQL
  module Types
    # AnswerValue for GraphQL
    class AnswerValue < BaseScalar
      # self.coerce_input takes a GraphQL input
      # and converts it into a Ruby value
      def self.coerce_input input_value, _context
        case input_value
        when Float, Integer
          input_value
        when String
          input_value.include?(",") ? input_value.split(", ") : input_value
        else
          input_value
        end
      end

      # self.coerce_result takes the return value of a field and
      # prepares it for the GraphQL response JSON
      def self.coerce_result ruby_value, _context
        return Integer(ruby_value) if integer?(ruby_value)
        return Float(ruby_value) if float?(ruby_value)
        if ruby_value.is_a?(String) && ruby_value.include?(",")
          return ruby_value.split(", ")
        else
          ruby_value
        end
      end

      def self.integer? value
        begin
          Integer(value)
        rescue ArgumentError
          false
        end
      end

      def self.float? value
        begin
          Float(value)
        rescue ArgumentError
          false
        end
      end
    end
  end
end
