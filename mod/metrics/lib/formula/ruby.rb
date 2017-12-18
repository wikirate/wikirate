# the processed formula is a block that expects as argument an
# array that contains the input values  needed to calculated the formula
# value in order of appearance in the formula

module Formula
  # Calculate formula values using Ruby
  # It converts the formula to a ruby lambda function
  # The formula may only consist of numbers and the symbols and functions
  # listed in SYMBOLS and FUNCTIONS
  class Ruby < Calculator
    SYMBOLS = %w{+ - ( ) [ ] . * , /}.freeze
    FUNCTIONS = { "Sum" => "sum", "Max" => "max", "Min" => "min",
                  "Zeros" => "count(0)", "Flatten" => "flatten",
                  "Unknowns" => "count('Unknown')" }.freeze
    LAMBDA_ARGS_NAME = "args".freeze

    INPUT_CAST = ->(val) { val.number? ? val.to_f : val }

    FUNC_KEY_MATCHER = FUNCTIONS.keys.join("|").freeze
    FUNC_VALUE_MATCHER = FUNCTIONS.values.join("|").freeze

    class << self
      def valid_formula? formula
        without_nests = remove_nests(formula)
        check_symbols remove_functions(without_nests)
      end

      def remove_functions formula, translated=false
        allowed = translated ? FUNCTIONS.values : FUNCTIONS.keys
        cleaned = formula.clone
        allowed.each do |word|
          cleaned = cleaned.gsub(word, "")
        end
        cleaned
        # matcher = translated ? FUNC_VALUE_MATCHER : FUNC_KEY_MATCHER
        # formula.gsub(/#{matcher}/,'')
      end

      def check_symbols formula
        symbols = SYMBOLS.map { |s| "\\#{s}" }.join
        formula =~ /^[\s\d#{symbols}]*$/
      end
    end

    def get_value input, _company, _year
      input.each_with_index do |inp, index|
        valid = validate_input inp, index
        return valid unless valid == true
      end
      @executed_lambda.call(input)
    end

    def validate_input input, index
      return true if  @non_numeric_ok.include?(index)
      input = Array.wrap(input)
      if input.all? { |inp| inp.is_a?(Float) }
        true
      elsif input.any? { |inp| inp.to_s.casecmp("unknown").zero? }
        "Unknown"
      elsif input.any?(&:empty?)
        nil
      else
        "invalid input"
      end
    end

    def to_lambda
      rb_formula =
        replace_nests(translate_functions(@formula)) do |index|
          "#{LAMBDA_ARGS_NAME}[#{index}]"
        end
      find_allowed_non_numeric_input rb_formula
      lambda_wrap rb_formula
    end

    protected

    def exec_lambda expr
      eval expr
    end

    def safe_to_exec? expr
      cleaned = if expr =~ /^lambda \{ \|args\| (.+)\}$/
                  Regexp.last_match(1).gsub(/args\[\d+\]/, "")
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
      formula.gsub(/(?<func>#{FUNC_KEY_MATCHER})\[(?<arg>[^\]]+)\]/) do |_match|
        arg = translate_functions $LAST_MATCH_INFO[:arg]
        "[#{arg}].flatten.#{FUNCTIONS[$LAST_MATCH_INFO[:func]]}"
      end
    end

    def lambda_wrap code
      "lambda { |#{LAMBDA_ARGS_NAME}| #{code} }"
    end

    def find_allowed_non_numeric_input formula
      @non_numeric_ok ||= ::Set.new
      formula.scan(/\[([^.]+)\]\.flatten\.count/) do |match|
        match.each do |args|
          args.scan(/#{LAMBDA_ARGS_NAME}\[(\d+)\]/) do |num|
            @non_numeric_ok += num.map(&:to_i)
          end
        end
      end
    end
  end
end
