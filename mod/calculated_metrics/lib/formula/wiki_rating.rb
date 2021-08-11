module Formula
  class WikiRating < JsonCalculator
    def get_value input, _company, _year
      result = 0.0
      total_weight = 0
      input.each.with_index do |value, index|
        weight = weight_from_index(index)
        result += value.to_f * weight
        total_weight += weight
      end
      result / total_weight
    end

    protected

    def weight_from_index index
      @executed[input.card_id(index)].to_f
    end

    def execute
      super.each_pair.with_object({}) do |(k, v), hash|
        hash[Card.fetch_id(k)] = v.to_f
      end
    end
  end
end
