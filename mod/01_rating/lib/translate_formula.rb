class TranslateFormula < Formula
  def get_value _year, metrics_with_values, _i
    values = metrics.map do |metric|
      if (v = metrics_with_values[metric])
        v.to_s.downcase
      else
        nil
      end
    end.compact
    if values.size > 1
      fail Card::Error, 'translate formula with more than one metric
involved'
    end
    @executed_lambda[values.first]
  end

  def get_single_value metrics_with_values
    if metrics_with_values.size > 1
      fail Card::Error, 'translate formula with more than one metric involved'
    end
    metrics_with_values.each_pair do |_metric, value|
      return @executed_lambda[value.to_s.downcase]
    end
  end

  def to_lambda
    @formula.content.downcase
  end



  protected

  def exec_lambda expr
    JSON.parse expr
  end

  def safe_to_exec? expr
    true
  end

  def insert_into_formula _metrics_with_values
    to_lambda
  end
end