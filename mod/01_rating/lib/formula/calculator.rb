  # encoding: UTF-8

  class Formula
    class Calculator
      def initialize formula_card
        @formula = formula_card
        @input = Formula::Input.new(@formula)
      end

      # @param [Hash] opts
      # @option opts [String] :company
      # @option opts [String] :year
      # @return [Hash] { year => { company => value } }
      def result opts={}
        compile_formula
        result = Hash.new_nested Hash
        @input.each(opts) do |year, company, input|
          next unless (value = get_value(input, company, year))
          result[year][company] = normalize_value value
        end
        result
      end

      # Returns all years that are affected by changes on the metric values given
      # by `changed_years`
      def update_range changed_years
        @multi_year ? :all : changed_years
        #return years unless @multi_year
      end

      def compile_formula expr=nil
        @executed_lambda = safe_execution(expr || to_lambda)
      end

      def cast_input val
        val
      end

      private

      def safe_execution expr
        return unless safe_to_exec?(expr)
        exec_lambda expr
      end

      protected

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

      def metrics
        @formula.input_metric_keys
      end

      def normalize_value value
        @formula.normalize_value value
      end
    end
  end
