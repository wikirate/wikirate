class RubyFormula < Formula
  def get_value year, metrics_with_values, i
    values = metrics.map do |metric|
      if (v = metrics_with_values[metric])
        v.to_f
      else
        nil
      end
    end.compact
    return if values.size != metrics.size
    @executed_lambda.call(values)
  end

  def to_lambda
    rb_formula = @formula.keyified
    metrics.each_with_index do |metric, i|
      rb_formula.gsub!("{{#{ metric }}}", "data[#{i}][year]")
    end
    "#{LAMBDA_PREFIX} #{rb_formula} }"
  end

  LAMBDA_PREFIX = "lambda { |data, year| "
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

  # allow only numbers, whitespace, mathematical operations
  def ruby_safe? expr
    expr.match(/^[\s\d+-\/*\.()]*$/)
  end
end

