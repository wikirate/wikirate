# encoding: UTF-8

module Formula
  class Calculation
    attr_reader :calculator, :input_answers, :company_id, :year

    def initialize calculator, input_answers, company_id, year
      @calculator = calculator
      @input_answers = input_answers
      @company_id = company_id
      @year = year
    end

    def input_values
      @input_values ||= input_answers.map { |a| a&.value }
    end

    def value
      calculator.result_value input_values, company_id, year
    end
  end
end