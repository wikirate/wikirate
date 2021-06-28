# encoding: UTF-8

module Formula
  # Calculates the values of a formula
  class Calculator
    include ShowWork

    attr_reader :errors

    # All the answers a given calculation depends on
    # (same opts as #result)
    # @return [Array] array of Answer objects
    delegate :answers, to: :input

    # @param parser [Formula::Parser]
    # @param normalizer: [Method] # called to normalize each *result* value
    def initialize parser, normalizer: nil
      @parser = parser
      @value_normalizer = normalizer
      @errors = []
    end

    def input
      @input ||= with_input_cards { Input.new @parser, &method(:cast) }
    end

    # Calculates answers
    # @param :companies [cardish, Array] only yield input for given companies
    # @option :years [String, Integer, Array] :year only yield input for given years
    # @return [Hash] { year => { company_id => value } }
    def result companies: nil, years: nil
      result_hash do |result|
        each_input(companies: companies, years: years) do |input, company, year|
          next unless (value = value_for_input input, company, year)
          result[year][company] = value
        end
      end
    end

    # The scope of results that would be calculated for given result options
    # (but without the actual calculated value)
    # @param [Hash] opts
    # @option opts [String] :company
    # @option opts [String, Array] :year
    # @return [Array] [company_id1, year1], [company_id2, year2], ... ]
    def result_scope opts={}
      [].tap do |res|
        each_input opts do |_input, company_id, year|
          res << [company_id, year]
        end
      end
    end

    # @return [Formula]
    def formula
      @formula ||= @parser.formula
    end

    # @return [Array] list of errors
    def detect_errors
      @errors = []
      compile_formula
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

    protected

    def compile_formula
      return unless safe_to_convert? formula
      @executed_lambda ||= safe_execution to_lambda
    end

    def safe_to_convert? _expr
      true
    end

    def safe_to_exec? _expr
      false
    end

    def normalize_value value
      @value_normalizer ? @value_normalizer.call(value) : value
    end

    # doesn't actually cast anything; overridden in other calculators
    def cast val
      val
    end

    private

    def with_input_cards
      @parser.input_cards.any?(&:nil?) ? InvalidInput.new : yield
    end

    def each_input opts
      input.each(opts) do |input, company, year|
        yield input, company, year
      end
    end

    def value_for_input input, company, year
      return "Unknown" if input == :unknown
      value = get_value input, company, year
      normalize_value value if value
    end

    def result_hash
      result = Hash.new_nested Hash
      yield result if compile_formula
      result
    end

    def safe_execution expr
      return if @errors.any?

      unless safe_to_exec?(expr)
        @errors << "invalid formula"
        return
      end
      exec_lambda expr
    end
  end
end
