module GraphQL
  module Types
    class AnswerValue < BaseScalar
      description "An answer value that can be either a string, an integer, a float or an array"

      def self.coerce_input(input_value, context)
        if input_value.is_a?(Float) or input_value.is_a?(Integer) or input_value.is_a?(BigDecimal) or input_value.is_a?(BigInt)
          input_value
        elsif input_value.to_s.include? ","
          input_value.split(",")
        else
          input_value
        end
      end

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
