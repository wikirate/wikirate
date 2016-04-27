class TranslateFormula < Formula
  def get_value input
    if input.size > 1
      fail Card::Error,
           'translate formula with more than one metric involved'
    end
    @executed_lambda[input.first.to_s.downcase]
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

  def self.valid_formula? formula
    formula =~ /^\{[^{}]*\}$/
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