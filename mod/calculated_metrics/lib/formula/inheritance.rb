
module Formula
  # Calculator for descendant metrics
  class Inheritance < Calculator
    def get_value input, _company, _year
      input.compact.first
    end

    def compile_formula
      true
    end
  end
end
