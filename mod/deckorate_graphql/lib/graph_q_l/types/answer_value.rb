module GraphQL
  module Types
    # AnswerValue for GraphQL
    class AnswerValue < BaseScalar
      class << self
        # self.coerce_input takes a GraphQL input
        # and converts it into a Ruby value
        def coerce_input input_value, _context
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
        def coerce_result ruby_value, _context
          if integer?(ruby_value)
            Integer(ruby_value)
          elsif float?(ruby_value)
            Float(ruby_value)
          elsif ruby_value.is_a?(String) && ruby_value.include?(",")
            ruby_value.split(", ")
          else
            ruby_value
          end
        end

        def integer? value
          Integer(value)
        rescue ArgumentError
          false
        end

        def float? value
          Float(value)
        rescue ArgumentError
          false
        end
      end
    end
  end
end
