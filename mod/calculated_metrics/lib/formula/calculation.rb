# encoding: UTF-8

module Formula
  # handle outputs for a given answer
  class Calculation
    attr_reader :calculator, :input_answers, :company_id, :year
    attr_writer :value

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
      @value ||= calculator.result_value input_values, company_id, year
    end
  end
end
