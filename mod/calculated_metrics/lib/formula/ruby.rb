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
    FUNCTIONS = { "Total" => "sum", "Max" => "max", "Min" => "min",
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
      elsif input.any? { |inp| Answer.unknown? inp }
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
      return unless formula.present?
      match = formula.match FUNC_KEY_MATCHER
      return formula unless match
      i = match.end(0)
      if formula[i] != "["
        @errors << "invalid formula: expected '[' at #{i}"
        return
      end
      arg, rest = func_arg(formula, i + 1).map(&method(:translate_functions))
      [formula[0, match.begin(0)], "[#{arg}].flatten.#{FUNCTIONS[match[0]]}", rest].join
    end

    # find argument for function in square brackets
    # @param formula [String]
    # @param offset [Integer] position after opening '[' where search the begins
    # @return function argument [String] and the rest of the formula [Integer]
    #    after the closing ']'
    def func_arg formula, offset
      i = offset
      br_cnt = 1
      while br_cnt > 0 do
        i += 1
        if i == formula.size
          @errors << "invalid formula: no closing ']' found for '[' at #{match.end(0)}"
          return
        end
        br_cnt += 1 if formula[i] == "["
        br_cnt -= 1 if formula[i] == "]"
      end
      arg_end = i - 1
      [formula[offset..arg_end], formula[arg_end + 2..-1]]
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
