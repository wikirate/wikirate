# encoding: UTF-8

module Formula
  # Calculates the values of a formula
  #
  # Calculator.new(formula_card)
  # The formula_card must respond to:
  #   #clean_formula: a String with just nests and operators
  #   #input_cards
  #   #input_chunks
  class Calculator
    INPUT_CAST = ->(val) { val }

    attr_reader :errors, :formula_card

    def initialize formula_card
      @formula_card = formula_card
      @input = ::Formula::Calculator::Input.new @formula_card, &self.class::INPUT_CAST
      @errors = []
    end

    # @param [Hash] opts
    # @option opts [String] :company
    # @option opts [String] :year
    # @return [Hash] { year => { company => value } }
    def result opts={}
      result = Hash.new_nested Hash
      return result unless compile_formula
      @input.each(opts) do |input, company, year|
        next unless (value = get_value(input, company, year))
        result[year][company] = normalize_value value
      end
      result
    end

    def answers_to_be_calculated opts={}
      res = []
      @input.each(opts) do |_input, company_id, year|
        res << [company_id, year]
      end
      res
    end

    def input_data company, year
      @formula_card.input_cards.zip(
        @input.input_for(company, year), formula_card.year_options
      )
    end

    # @return [String] the formula with nests replaced by the input values
    #   A block can be used to format the input values
    def formula_for company, year
      input_enum = @input.input_for(company, year).each
      replace_nests do
        block_given? ? yield(input_enum.next) : input_enum.next
      end
    end

    # provides (in contrast to formula_for) also the input metric and index for every input
    # and not only the input value for formatting the formula
    # @return [String] the formula with nests replaced by the result of the given block
    def advanced_formula_for company, year
      input_enum = @input.input_for(company, year).each
      replace_nests do |index|
        yield(input_enum.next, @formula_card.input_cards[index], index)
      end
    end

    def formula
      @formula ||= @formula_card.clean_formula
    end

    def validate_formula
      compile_formula
      @errors
    end

    def self.remove_nests content
      content.gsub(/{{[^}]*}}/, "")
    end

    private

    def safe_execution expr
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
      content.gsub(/{{[^}]*}}/) do |_match|
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

    def normalize_value value
      @formula_card.normalize_value value
    end
  end
end
