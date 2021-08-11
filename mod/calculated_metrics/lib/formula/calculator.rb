# encoding: UTF-8

module Formula
  # Calculates the values of a formula
  class Calculator
    include ShowWork
    include Restraints

    attr_reader :errors

    # All the answers a given calculation depends on
    # (same opts as #result)
    # @return [Array] array of Answer objects
    delegate :answers, to: :input

    # @param parser [Formula::Parser]
    # @param normalizer: [Method] # called to normalize each *result* value
    # @param years: [String, Integer, Array] applicable year or years
    # @param companies: [String, Integer, Array] applicable company or companies
    def initialize parser, normalizer: nil, years: nil, companies: nil
      @parser = parser
      @applicable_years = years
      @applicable_companies = companies
      @normalizer = normalizer
      @errors = []
    end

    def input
      @input ||= with_input_cards { Input.new @parser, &method(:cast) }
    end

    # Calculates answers
    # @param :companies [Array, Integer] only yield input for given companies
    # @param :years [String, Integer, Array] :year only yield input for given years
    # @return [Hash] { year => { company_id => value } }
    def result **restraints
      result_hash do |result|
        each_input(**restraints) do |input, company, year|
          next unless (value = value_for_input input, company, year)
          result[year][company] = value
        end
      end
    end

    # The scope of results that would be calculated for given result options
    # (but without the actual calculated value)
    # @param :companies [Array, Integer] only yield input for given companies
    # @param :years [String, Integer, Array] :year only yield input for given years
    # @return [Array] [company_id1, year1], [company_id2, year2], ... ]
    def result_scope **restraints
      [].tap do |results|
        each_input(**restraints) do |_input, company_id, year|
          results << [company_id, year]
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

    def executable
      @executable ||= build_executable
    end

    protected

    def compile_formula
      return unless safe_to_convert? formula
      @executed ||= safely_execute
    end

    def safe_to_convert? _expr
      true
    end

    def safe_to_exec?
      false
    end

    def normalize_value value
      @normalizer ? @normalizer.call(value) : value
    end

    # doesn't actually cast anything; overridden in other calculators
    def cast val
      val
    end

    private

    def with_input_cards
      @parser.input_cards.any?(&:nil?) ? InvalidInput.new : yield
    end

    # @param :companies [Integer Array] only yield input for given companies
    # @param :years [String, Integer, Array] :year only yield input for given years
    def each_input companies: nil, years: nil
      with_restraints companies, years do |c, y|
        input.each(companies: c, years: y) do |input, company, year|
          yield input, company, year
        end
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

    def safely_execute
      return if @errors.any? || (!safe_to_exec? && @errors << "invalid formula")

      execute
    rescue StandardError => e
      @errors << e.message
    end
  end
end
