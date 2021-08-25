include_set Abstract::HardCodedFormula

def calculator_class
  Calculate::IsicSection
end

format :html do
  view :core do
    ["Translate number into letter category:", render_variable_metrics]
  end
end
