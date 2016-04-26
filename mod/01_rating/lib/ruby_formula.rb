# the processed formula is a block that expects as argument an
# array that contains the input values  needed to calculated the formula
# value in order of appearance in the formula


class RubyFormula < Formula
  SYMBOLS = %w{+ - ( ) [ ] . * /}.freeze
  FUNCTIONS = { 'Sum' => 'sum' }.freeze

  FUNC_MATCHER =  FUNCTIONS.keys.join('|').freeze
  LAMBDA_PREFIX = 'lambda { |args| '.freeze

  def get_value year, company
    return unless (input = formula_input(year, company))
    @executed_lambda.call(input)
  end

  def translate_functions formula
    formula.gsub(/(?<func>#{FUNC_MATCHER})\[(?<arg>.+)\]/) do |match|
      arg = translate_functions $~[:arg]
      "#{arg}.#{FUNCTIONS[$~[:func]]}"
    end
  end

  def to_lambda
    rb_formula = translate_functions @formula.content
    index = -1
    rb_formula.gsub!(/{{[^}]*}}/) do |match|
      index += 1
      "args[#{index}]"
    end
    "#{LAMBDA_PREFIX} #{rb_formula} }"
  end

  protected

  def cast_input val
    val.to_f
  end

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

  # allow only numbers, whitespace, mathematical operations
  def ruby_safe? expr
    without_func = expr.gsub(/\.#{FUNCTIONS.values.join('|')}/,'')
    symbols = SYMBOLS.map { |s| "\\#{s}"}.join
    without_func.match(/^[\s\d#{symbols}]*$/)
  end
end

