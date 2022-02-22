class Calculate
  # Formula that translates one value to another based on a JSON map
  class Rubric < Calculator
    def compute input, _company, _year
      if input.size > 1
        raise Card::Error, "translate formula with more than one metric involved"
      end
      # For multi-category metrics a value can be a list of value.
      # In that case map every item and take the sum.
      Array.wrap(input.first).inject(0.0) do |res, inp|
        res + (formula[inp.to_s.downcase] || formula["else"]).to_f
      end
    end
  end
end
