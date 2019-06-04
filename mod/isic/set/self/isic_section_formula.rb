include_set Abstract::HardCodedFormula

def calculator_class
  Formula::IsicSection
end

format :html do
  view :core do
    ["Translate number into letter category:", render_variable_metrics]
  end
end
