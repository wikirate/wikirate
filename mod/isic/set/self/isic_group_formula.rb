include_set Abstract::HardCodedFormula

def get_value input
  input.first.map(&:chop).uniq
end

format :html do
  view :core do
    ["The first three digits of:", render_variable_metrics]
  end
end
