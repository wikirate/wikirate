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

    def answer_attributes
      {
        company_id: company_id,
        year: year,
        value: value,
        numeric_value: Answer.to_numeric(value),
        created_at: Time.now,
        updated_at: Time.now,
        creator_id: Card::Auth.current_id,
        updater_id: Card::Auth.current_id,
        imported: false,
        calculating: false
      }
    end
  end
end
