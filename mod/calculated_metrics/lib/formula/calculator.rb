# encoding: UTF-8

module Formula
  # Calculates the values of a formula
  #
  # Calculator.new(formula_card)
  # The formula_card must respond to:
  #   #clean_formula: a String with just nests and operators
  #   #input_cards: array of cards
  #   #company_options: array of the same size as input card with a company option string
  #                    for each input card
  #   #year_options: array of the same size as input card with a year option string
  #   #              for each input card
  class Calculator
    INPUT_CAST = ->(val) { val }

    attr_reader :errors, :input

    delegate :answers, to: :input

    def initialize parser, &value_normalizer
      @value_normalizer = value_normalizer
      @parser = parser
      @input = initialize_input
      @errors = []
    end

    # Calculates answers
    # If a company or a year is given it calculates only answers only for those
    # @param [Hash] opts
    # @option opts [String] :company
    # @option opts [String] :year
    # @return [Hash] { year => { company => value } }
    def result opts={}
      result_hash do |result|
        each_input(opts) do |input, company, year|
          next unless (value = value_for_input input, company, year)
          result[year][company] = value
        end
      end
    end

    def each_input opts
      @input.each(opts) do |input, company, year|
        yield input, company, year
      end
    end

    def answers_to_be_calculated opts={}
      [].tap do |res|
        each_input opts do |_input, company_id, year|
          res << [company_id, year]
        end
      end
    end

    def input_data company, year
      @parser.input_cards.zip(
        Array.wrap(@input.input_for(company, year)), @parser.year_options
      )
    end

    # @param [Proc] block . Block that can handle three args:
    #     1: raw input value
    #     2. input metric card
    #     3. the year index
    # @return [String] the formula with nests replaced by the result of the given block
    def formula_for company, year, &block
      input = @input.input_for(company, year)
      case input
      when :unknown
        "Unknown"
      when nil
        "No value"
      else
        formula_with_nests input, &block
      end
    end

    def formula_with_nests input
      input_enum = input.each
      replace_nests do |index|
        yield input_enum.next, @parser.input_cards[index], index
      end
    end


    def formula
      @formula ||= @parser.formula
    end

    def validate_formula
      @errors = []
      compile_formula
      @errors
    end

    def self.remove_nests content
      content.gsub(/{{[^}]*}}/, "")
    end

    def self.remove_quotes content
      content.gsub(/"[^"]+"/, "")
    end

    private

    def initialize_input
      if @parser.input_cards.any?(&:nil?)
        InvalidInput.new
      else
        Input.new @parser, &self.class::INPUT_CAST
      end
    end

    def safe_execution expr
      return if @errors.any?

      unless safe_to_exec?(expr)
        @errors << "invalid formula"
        return
      end
      exec_lambda expr
    end

    protected

    def compile_formula
      return unless safe_to_convert? formula
      @executed_lambda ||= safe_execution(to_lambda)
    end

    def replace_nests content=nil
      content ||= formula
      index = -1
      content.gsub(/{{[^{}]*}}/) do |_match|
        index += 1
        yield(index)
      end
    end

    def safe_to_convert? _expr
      true
    end

    def safe_to_exec? _expr
      false
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

    def normalize_value value
      @value_normalizer ? @value_normalizer.call(value) : value
    end
  end
end
