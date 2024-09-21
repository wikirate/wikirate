class Calculate
  # methods for computing Ratings (metric type for weighted averages)
  class Rating < Calculator
    def compute input_vals, _company, _year
      result = 0.0
      total_weight = 0
      input_vals.each.with_index do |value, index|
        weight = weights[index]
        result += value.to_f * weight
        total_weight += weight
      end
      result / total_weight
    end

    protected

    def weights
      @weights ||= input.input_list.map { |input_item| input_item.options[:weight].to_f }
    end
  end
end
