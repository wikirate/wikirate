include_set Abstract::Hybrid
include_set Abstract::Calculation

def calculator_class
  Calculate::JavaScript
end

format :html do
  view :formula do
    field_nest :formula, view: :variables_and_formula
  end
end
