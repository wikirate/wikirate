# encoding: UTF-8

module Formula
  # Calculates the values of a formula
  class Calculator
    INPUT_CAST = ->(val) { val }

    attr_reader :formula, :errors

    def initialize formula_card
      @formula = formula_card
      @input = Input.new(@formula.input_cards, year_options,
                         &self.class::INPUT_CAST)
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
      return unless safe_to_convert? @formula.content
      @executed_lambda ||= safe_execution(to_lambda)
    end

    # Extracts all year options from all input nests in the formula
    def year_options
      @formula.input_chunks.map do |chunk|
        chunk.options[:year]
      end
    end

    def replace_nests content=nil
      content ||= @formula.content
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
      @formula.normalize_value value
    end
  end
end
