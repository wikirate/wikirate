include_set Abstract::HardCodedFormula

# @param input [Array of Arrays] ...of 3 digit ISIC group codes
# @return [Array] ... of 2 digit division codes
def get_value input
  input.first.map(&:chop).uniq
end

format :html do
  view :core do
    ["The first two digits of:", render_variable_metrics]
  end
end
