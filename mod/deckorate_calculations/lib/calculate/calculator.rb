# encoding: UTF-8

class Calculate
  # Base class for calculators that can compute the values of a formula
  #
  # Different calculator implementations share the same 3 main phases:
  #
  # 1. program phase: converts the formula into a "program" via #compile method
  # 2. boot phases: loads formula into a "computer" via a #boot method
  # 3. computation phase: converts inputs into outputs via a #compute method.
  class Calculator
    include ShowWork
    include Restraints

    attr_reader :errors, :computer, :formula

    # All the answer a given calculation depends on
    # (same opts as #result)
    # @return [Array] array of Answer objects
    delegate :answer_for, to: :input

    # @param input_array [Array]
    # @param normalizer: [Method] # called to normalize each *result* value
    # @param years: [String, Integer, Array] applicable year or years
    # @param companies: [String, Integer, Array] applicable company or companies
    def initialize input_array, formula: nil, normalizer: nil, years: nil, companies: nil
      @input_array = input_array
      @formula = formula
      @applicable_years = integers years
      @applicable_companies = integers companies
      @normalizer = normalizer
      @errors = []
    end

    def input
      @input ||= input_with :cast
    end

    # Calculates answer
    # @param :companies [Array, Integer] only yield input for given companies
    # @param :years [String, Integer, Array] :year only yield input for given years
    # @return [Hash] { year => { company_id => value } }
    def result **restraints
      restrain_to(**restraints)
      result_array do |result|
        each_answer do |input_answers, company, year|
          result << Calculation.new(company, year, calculator: self,
                                                   input_answers: input_answers)
        end
      end
    end

    # @return [Array] list of errors
    def detect_errors
      reset
      ready?
      @errors
    end

    class << self
      def remove_nests content
        content.gsub(/{{[^}]*}}/, "")
      end

      def remove_quotes content
        content.gsub(/"[^"]+"/, "")
      end
    end

    def program
      @program ||= @formula
    end

    def ready?
      true
    end

    def reset
      @computer = @program = nil
      @errors = []
    end

    def result_value input_values, company, year
      return "Unknown" if result_is_unknown? input_values
      result = compute input_values, company, year
      normalize_value result if result
    end

    def input_values
      each_answer do |input_answers, company, year|
        values = input_answers&.map { |a| a&.value }
        next if result_is_unknown? values
        yield values, company, year
      end
    end

    def raw_input_values
      [].tap do |list|
        each_answer do |input_answers, _company, _year|
          list << input_answers&.map { |a| a&.value }
        end
      end
    end

    protected

    def result_is_unknown? input_values
      input_values.first == :unknown
    end

    def normalize_value value
      @normalizer ? @normalizer.call(value) : value
    end

    # doesn't actually cast anything; overridden in other calculators
    def cast val
      val
    end

    private

    def input_with cast=:cast
      if @input_array.present?
        Input.new @input_array, &method(cast)
      else
        InvalidInput.new
      end
    end

    # @param :companies [Integer Array] only yield input for given companies
    # @param :years [String, Integer, Array] :year only yield input for given years
    def each_answer
      with_restraints do |c, y|
        input.each(companies: c, years: y) do |input_answers, company, year|
          yield input_answers, company, year
        end
      end
    end

    def result_array
      result = []
      yield result if ready?
      result
    end
  end
end
