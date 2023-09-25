module GraphQL
  module Types
    # AnswerValue for GraphQL
    class AnswerValue < BaseScalar
      description "An answer value that can be either a string, an integer, a float or an array"

      # self.coerce_input takes a GraphQL input and converts it into a Ruby value
      def self.coerce_input(input_value, context)
        case input_value
        when Float, Integer, BigDecimal, BigInt
          input_value
        else
          if input_value.to_s.include? ","
            input_value.split(",")
          else
            input_value
          end
        end
      end

      # self.coerce_result takes the return value of a field and prepares it for the GraphQL response JSON
      def self.coerce_result(ruby_value, context)
        begin
          Integer(ruby_value) rescue
            begin
              Float(ruby_value) rescue
                begin
                  BigInt(ruby_value) rescue
                    begin
                      BigDecimal(ruby_value) rescue
                        if ruby_value.to_s.include? ","
                          ruby_value.split(", ")
                        else
                          ruby_value
                        end
                    end
                end
            end
        end
      end
    end
  end
end
