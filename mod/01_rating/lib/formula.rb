# encoding: UTF-8

class Formula
  def initialize formula_card
    @formula = formula_card
  end

  def evaluate
    @executed_lambda = exec_lambda(to_lambda)
    result = Hash.new { |h, k| h[k] = {} }
    @formula.input_values.each_pair do |year, companies|
       companies.each_pair.with_index do |(company, metrics_with_values), i|
         value = get_value year, metrics_with_values, i
         result[year][company] = normalize_value value
       end
    end
    result
  end

  def evaluate_single_input metrics_with_values
    expr = insert_into_formula metrics_with_values
    return if expr.match(/\{\{([^}]+)\}\}/) # missing input values
    normalize_value exec_lambda(expr)
  end

  protected

  def insert_into_formula metrics_with_values
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
