module Formula
  # Formula that translates one value to another based on a JSON map
  class Translation < JsonCalculator
    def initialize parser, **_opts
      parser.unknown_handling :unknown_string
      super
    end

    def build_executable
      super.downcase
    end

    def get_value input, _company, _year
      if input.size > 1
        raise Card::Error, "translate formula with more than one metric involved"
      end
      # For multi-category metrics a value can be a list of value.
      # In that case map every item and take the sum.
      Array.wrap(input.first).inject(0.0) do |res, inp|
        res + (executed[inp.to_s.downcase] || executed["else"]).to_f
      end
    end
  end
end
