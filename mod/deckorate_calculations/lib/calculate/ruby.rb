# the processed formula is a block that expects as argument an
# array that contains the input values  needed to calculated the formula
# value in order of appearance in the formula

class Calculate
  # Calculate formula values using Ruby
  # It converts the formula to a ruby lambda function
  # The formula may only consist of numbers and the symbols and functions
  # listed in SYMBOLS and FUNCTIONS
  class Ruby < NestCalculator
    extend RubyClassMethods

    SYMBOLS = %w[+ - ( ) \[ \] . * , / || && { }].freeze
    FUNCTIONS = {
      "Total" => "sum",
      "Max" => "max",
      "Min" => "min",
      "Zeros" => "count(0)",
      "Flatten" => "flatten",
      "Unknowns" => "count('Unknown')",
      "Country" => "country_lookup",
      "ILORegion" => "ilo_region_lookup"
    }.freeze
    LOOKUPS = ::Set.new %w[Country ILORegion]
    LAMBDA_ARGS_NAME = "args".freeze

    def cast val
      val.number? ? val.to_f : val
    end

    FUNC_KEY_MATCHER = FUNCTIONS.keys.join("|").freeze

    def compute values, _company, _year
      values.each_with_index do |val, index|
        valid = validate_input_value val, index
        return valid unless valid == true
      end
      computer.call(values)
    end

    def validate_input_value input, index
      return true if @non_numeric_ok.include?(index)

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

    def compile
      rb_formula = translate %i[functions nests list_syntax], formula
      find_allowed_non_numeric_input rb_formula
      lambda_wrap rb_formula
    rescue Calculator::FunctionTranslator::SyntaxError => e
      @errors << e.message
    end

    def bootable?
      ruby_safe? cleaned_program
    end

    protected

    def cleaned_program
      m = program.match(/^lambda \{ \|args\| (?<raw_program>.+)\}$/)
      return program unless m

      m[:raw_program].gsub(/args\[\d+\]/, "")
    end

    def boot
      eval program
    end

    def country_lookup region
      lookup_for_region region, :country
    end

    def ilo_region_lookup region
      lookup_for_region region, :ilo_region
    end

    def lookup_for_region region, field
      region_id = region.card_id
      country = Card::Region.lookup_val(field)[region_id] if region_id
      country || "#{field} not found"
    end

    private

    def translate methods, arg
      methods = Array.wrap(methods).map { |m| "translate_#{m}" }
      methods.inject(arg) do |ret, method|
        send method, ret
      end
    end

    def translate_functions f=formula
      function_translator.translate f
    end

    def translate_nests formula
      replace_nests(formula) { |index| "#{LAMBDA_ARGS_NAME}[#{index}]" }
    end

    def translate_list_syntax formula
      formula.tr("{}", "[]")
    end

    def function_translator
      @function_translator ||=
        Calculator::FunctionTranslator.new(FUNCTIONS) do |func, replacement, arg|
          if LOOKUPS.include? func
            "#{replacement}(#{arg})"
          else
            "[#{arg}].flatten.#{replacement}"
          end
        end
    end

    def ruby_safe? expr
      without_func = self.class.remove_functions expr, true
      self.class.check_symbols without_func
    end

    def lambda_wrap code
      "lambda { |#{LAMBDA_ARGS_NAME}| #{code} }"
    end

    def find_allowed_non_numeric_input formula
      @non_numeric_ok ||= ::Set.new
      formula.scan(self.class.function_re) do |match|
        match.compact.each do |args|
          args.scan(/#{LAMBDA_ARGS_NAME}\[(\d+)\]/) do |num|
            @non_numeric_ok += num.map(&:to_i)
          end
        end
      end
    end
  end
end
