# encoding: UTF-8

module Formula
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

    attr_reader :errors, :computer

    # All the answers a given calculation depends on
    # (same opts as #result)
    # @return [Array] array of Answer objects
    delegate :answers_for, to: :input

    # @param parser [Formula::Parser]
    # @param normalizer: [Method] # called to normalize each *result* value
    # @param years: [String, Integer, Array] applicable year or years
    # @param companies: [String, Integer, Array] applicable company or companies
    def initialize parser, normalizer: nil, years: nil, companies: nil
      @parser = parser
      @applicable_years = integers years
      @applicable_companies = integers companies
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
      restrain_to(**restraints)
      result_hash do |result|
        each_answer do |input, company, year|
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
      restrain_to(**restraints)
      [].tap do |results|
        each_answer do |_input, company_id, year|
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
      @program ||= compile
    end

    def ready?
      return false unless programmable? formula
      @computer ||= safely_boot
      @errors.empty?
    end

    def programmable? _expr
      true
    end

    def bootable?
      true
    end

    def reset
      @computer = @program = nil
      @errors = []
    end

    protected

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
    def each_answer
      with_restraints do |c, y|
        input.each(companies: c, years: y) do |answer, company, year|
          yield answer.value, company, year
        end
      end
    end

    def value_for_input input, company, year
      return "Unknown" if input == :unknown
      value = compute input, company, year
      normalize_value value if value
    end

    def result_hash
      result = Hash.new_nested Hash
      yield result if ready?
      result
    end

    def safely_boot
      return if @errors.any? || (!bootable? && @errors << "invalid formula")

      boot
      # rescue StandardError => e
      #   @errors << e.message
    end
  end
end
