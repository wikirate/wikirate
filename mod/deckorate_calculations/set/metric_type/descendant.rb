include_set Abstract::Hybrid
include_set Abstract::Calculation

# OVERRIDES
def descendant?
  true
end

def calculator_class
  ::Calculate::Inheritance
end

format do
  view :legend do
    return unless (ancestor = card.formula_card.input_names.first)
    nest ancestor, view: :legend
  end
end

format :html do
  view :formula do
    field_nest :variables, view: :descendant_formula
  end
end
