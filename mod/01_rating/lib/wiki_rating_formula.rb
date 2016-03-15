class WikiRatingFormula < TranslateFormula
  def get_value _year, metrics_with_values, _i
    get_single_value metrics_with_values
  end

  def get_single_value metrics_with_values
    result = 0.0
    metrics.each do |metric|
      if (v = metrics_with_values[metric])
        weight = @executed_lambda[metric]
        result += v.to_f * weight
      else
        return nil
      end
    end
    result / 100
  end

  protected

  def exec_lambda expr
    JSON.parse(expr).each_pair.with_object({}) do |(k, v), hash|
      hash[k.to_name.key] = v
    end
  end
end