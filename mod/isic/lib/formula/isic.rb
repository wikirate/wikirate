module Formula
  # Calculator class for ISIC division and group codes
  class Isic < HardCoded
    # @param input [Array of Arrays] ...of 3 digit ISIC group codes
    # @return [Array] ... of 2 digit division codes
    # or
    # # @param input [Array of Arrays] ...of 4 digit ISIC (class) codes
    # # @return [Array] ... of 3 digit group codes
    def value_for_validated_input input, _company, _year
      input.first.map(&:chop).uniq
    end
  end
end
