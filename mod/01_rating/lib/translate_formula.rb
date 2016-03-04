class TranslateFormula < Formula


  def get_value year, metrics_with_values, i

    values = metrics.map do |metric|
      if (v = metrics_with_values[metric])
        v.to_s
      else
        nil
      end
    end.compact
    if values.size > 1
      fail Card::Error, 'Translate formula with more than one metric involved'
    end
    @executed_lambda[values.first]
  end

  def to_lambda
    json = @formula.gsub('=>',':')
    "{#{json}}"
  end

  def exec_lambda expr
    JSON.parse expr
  end

  def safe_to_exec? expr
    true
  end
end