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
      def self.coerce_result(ruby_value, _context)
        if integer? ruby_value
          Integer(ruby_value)
        elsif float? ruby_value
          Float(ruby_value)
        elsif big_int? ruby_value
          BigInt(ruby_value)
        elsif big_decimal? ruby_value
          BigDecimal(ruby_value)
        elsif ruby_value.to_s.include?(",")
          ruby_value.split(", ")
        else
          ruby_value
        end
      end

      def self.integer?(value)
        begin
          Integer(value)
        rescue ArgumentError
          false
        end

        def self.float?(value)
          begin
            Float(value)
          rescue ArgumentError
            false
          end
        end

        def self.big_int?(value)
          begin
            defined?(BigInt) && BigInt(value)
          rescue ArgumentError
            false
          end
        end

        def self.big_decimal?(value)
          begin
            defined?(BigDecimal) && BigDecimal(value)
          rescue ArgumentError
            false
          end
        end
      end
    end
  end
end
