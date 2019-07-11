module Formula
  # Formula that translates one value to another based on a JSON map
  class Translation < JsonFormula
    def initialize parser, &value_normalizer
      parser.pass_through_unknown!
      super
    end

    def get_value input, _company, _year
      if input.size > 1
        raise Card::Error,
              "translate formula with more than one metric involved"
      end
      # For multi-category metrics a value can be a list of value.
      # In that case map every item and take the sum.
      Array.wrap(input.first).inject(0.0) do |res, inp|
        res + (@executed_lambda[inp.to_s.downcase] || @executed_lambda["else"]).to_f
      end
    end

    protected
  end
end
