# encoding: UTF-8

module Formula
  class Calculator
    INPUT_CAST = lambda { |val| val }

    attr_reader :formula

    def initialize formula_card
      @formula = formula_card
      @input = Input.new(@formula.input_cards, year_options,
                         &self.class::INPUT_CAST)
    end

    # @param [Hash] opts
    # @option opts [String] :company
    # @option opts [String] :year
    # @return [Hash] { year => { company => value } }
    def result opts={}
      compile_formula
      result = Hash.new_nested Hash
      @input.each(opts) do |input, company, year|
        next unless (value = get_value(input, company, year))
        result[year][company] = normalize_value value
      end
      result
    end

    # Returns all years that are affected by changes on the metric values given
    # by `changed_years`
    # def update_range changed_years
    #   @multi_year ? :all : changed_years
    #   #return years unless @multi_year
    # end

    private

    def safe_execution expr
      return unless safe_to_exec?(expr)
      exec_lambda expr
    end

    protected

    def compile_formula expr=nil
      @executed_lambda = safe_execution(expr || to_lambda)
    end

    def year_options
      @formula.input_chunks.map do |chunk|
        chunk.options[:year]
      end
    end

    def replace_nests content=nil
      content ||= @formula.content
      index = -1
      content.gsub!(/{{[^}]*}}/) do |match|
        index += 1
        yield(index)
      end
    end

    def safe_to_exec? expr
      false
    end

    def normalize_value value
      @formula.normalize_value value
    end
  end
end


