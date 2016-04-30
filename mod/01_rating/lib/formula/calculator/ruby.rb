# the processed formula is a block that expects as argument an
# array that contains the input values  needed to calculated the formula
# value in order of appearance in the formula


class Ruby < Formula::Calculator
  SYMBOLS = %w{+ - ( ) [ ] . * /}.freeze
  FUNCTIONS = { 'Sum' => 'sum', 'Max' => 'max', 'Min' => 'min' }.freeze

  FUNC_MATCHER =  FUNCTIONS.keys.join('|').freeze
  LAMBDA_PREFIX = 'lambda { |args| '.freeze

  class << self
    def valid_formula? formula
      check_symbols remove_functions(formula)
    end

    def remove_functions formula, translated=false
      matcher = translated ? FUNCTIONS.values.join('|') : FUNC_MATCHER
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

  def translate_functions formula
    formula.gsub(/(?<func>#{FUNC_MATCHER})\[(?<arg>.+)\]/) do |match|
      arg = translate_functions $~[:arg]
      "#{arg}.#{FUNCTIONS[$~[:func]]}"
    end
  end

  def to_lambda
    rb_formula =
      replace_nests(translate_functions(@formula.content)) do |index|
        "args[#{index}]"
      end
    "#{LAMBDA_PREFIX} #{rb_formula} }"
  end

  def cast_input val
    val.to_f
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
    without_func = RubyFormula.remove_functions expr, true
    RubyFormula.check_symbols without_func
  end
end

