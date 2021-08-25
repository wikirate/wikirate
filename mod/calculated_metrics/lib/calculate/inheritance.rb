
class Calculate
  # Calculator for descendant metrics
  class Inheritance < Calculator
    def compute input, _company, _year
      input.compact.first
    end

    def ready?
      true
    end
  end
end
