module Formula
  class HardCoded < Calculator
    def get_value input, _company, _year
      formula_card.get_value input
    end

    def compile_formula
      true
    end

    def validate_input input, index
      formula_card.validate_input input, index
    end

    def normalize_value value
      formula_card.normalize_value value
    end
  end
end
