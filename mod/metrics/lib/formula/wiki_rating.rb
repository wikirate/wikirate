module Formula
  class WikiRating < Translation
    def get_value input, _company, _year
      result = 0.0
      input.each.with_index do |value, index|
        weight = @executed_lambda[@input.key(index)]
        result += value.to_f * weight
      end
      result / 100
    end

    protected

    def exec_lambda expr
      JSON.parse(expr).each_pair.with_object({}) do |(k, v), hash|
        hash[k.to_name.key] = v.to_f
      end
    rescue JSON::ParserError => _e
      @errors << "invalid WikiRating formula #{expr}"
      return false
    end
  end
end
