class Calculate
  # for formula that are hard-coded in Metric+Formula cards
  # (those cards will include the Abstract::HardCodedFormula set)
  class HardCoded < Calculator
    # unlike user contributed formulae, hard-coded formulae should always be valid
    def ready?
      true
    end

    # The following three method pass calculation, validation, and normalization
    # responsibilities to the formula card
    def compute input, company=nil, year=nil
      return unless validate_input input
      value_for_validated_input input, company, year
    end

    private

    # by default only validates that input is not unknown
    def validate_input input
      no_unknowns? input
    end

    def no_unknowns? input
      Array.wrap(input).flatten.none? { |inp| Answer.unknown? inp }
    end
  end
end
