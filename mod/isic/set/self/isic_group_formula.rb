include_set Abstract::HardCodedFormula

# @param input [Array of Arrays] ...of 4 digit ISIC (class) codes
# @return [Array] ... of 3 digit group codes
def get_value input
  input.first.map(&:chop).uniq
end

format :html do
  view :core do
    ["The first three digits of:", render_variable_metrics]
  end
end
