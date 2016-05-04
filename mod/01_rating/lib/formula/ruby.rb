# the processed formula is a block that expects as argument an
# array that contains the input values  needed to calculated the formula
# value in order of appearance in the formula

module Formula
  class Ruby < Calculator
    SYMBOLS = %w{+ - ( ) [ ] . * /}.freeze
    FUNCTIONS = { 'Sum' => 'sum', 'Max' => 'max', 'Min' => 'min' }.freeze
    LAMBDA_ARGS_NAME = 'args'.freeze

    INPUT_CAST = lambda { |val| val.to_f }

    FUNC_KEY_MATCHER =  FUNCTIONS.keys.join('|').freeze
    FUNC_VALUE_MATCHER =  FUNCTIONS.values.join('|').freeze

    class << self
      def valid_formula? formula
        check_symbols remove_functions(formula)
      end

      def remove_functions formula, translated=false
        matcher = translated ? FUNC_VALUE_MATCHER : FUNC_KEY_MATCHER
        formula.gsub(/#{matcher}/,'')
      end

      def check_symbols formula
        symbols = SYMBOLS.map { |s| "\\#{s}"}.join
        formula =~ (/^[\s\d#{symbols}]*$/)
      end
    end

    def get_value input, _company, _year
      @executed_lambda.call(input)
    end

    def to_lambda
      rb_formula =
        replace_nests(translate_functions(@formula.content)) do |index|
          "#{LAMBDA_ARGS_NAME}[#{index}]"
        end
      lambda_wrap rb_formula
    end

    protected

    def exec_lambda expr
      eval expr
    end

    def safe_to_exec? expr
      cleaned = if expr.match(/^lambda \{ \|args\| (.+)\}$/)
                $1.gsub(/args\[\d+\]/,'')
              else
                expr
              end
      ruby_safe? cleaned
    end

    def ruby_safe? expr
      without_func = self.class.remove_functions expr, true
      self.class.check_symbols without_func
    end

    private

    def translate_functions formula
      formula.gsub(/(?<func>#{FUNC_KEY_MATCHER})\[(?<arg>.+)\]/) do |match|
        arg = translate_functions $~[:arg]
        "#{arg}.#{FUNCTIONS[$~[:func]]}"
      end
    end

    def lambda_wrap code
      "lambda { |#{LAMBDA_ARGS_NAME}| #{code} }"
    end
  end
end
