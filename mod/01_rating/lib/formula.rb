# encoding: UTF-8

class Formula
  def initialize formula_card
    @formula = formula_card
  end

  def evaluate
    compile
    result = Hash.new { |h, k| h[k] = {} }
    @formula.input_values.each_pair do |year, companies|
       companies.each_pair.with_index do |(company, metrics_with_values), i|
         value = get_value year, metrics_with_values, i
         result[year][company] = normalize_value value
       end
    end
    result
  end

  def evaluate_single_input year, metrics_with_values
    expr = insert_into_formula year, metrics_with_values
    return if expr.match(/\{\{([^}]+)\}\}/) # missing input values
    compile expr
    normalize_value get_single_value(metrics_with_values)
  end

  def compile expr=nil
    @executed_lambda = safe_execution(expr || to_lambda)
  end

  def get_single_value _metrics_with_values
    @executed_lambda
  end

  private

  def safe_execution expr
    return unless safe_to_exec?(expr)
    exec_lambda expr
  end

  protected

  def safe_to_exec? expr
    false
  end

  def insert_into_formula year, metrics_with_values
    result = @formula.keyified
    metrics_with_values.each_pair do |metric, value|
      result.gsub! "{{#{metric}}}", value
    end
    result
  end

  def metrics
    @formula.input_metric_keys
  end

  def normalize_value value
    @formula.normalize_value value
  end
end
