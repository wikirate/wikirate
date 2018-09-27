module Formula
  # for formula that are hard-coded in Metric+Formula cards
  # (those cards will include the Abstract::HardCodedFormula set)
  class HardCoded < Calculator

    # unlike user contributed formulae, hard-coded formulae should always be valid
    def compile_formula
      true
    end

    # The following three method pass calculation, validation, and normalization
    # responsibilities to the formula card
    def get_value input, _company, _year
      @formula_card.get_value input
    end

    def validate_input input, index
      @formula_card.validate_input input, index
    end

    def normalize_value value
      @formula_card.normalize_value value
    end
  end
end
