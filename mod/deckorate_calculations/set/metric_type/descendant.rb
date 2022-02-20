include_set Abstract::Hybrid
include_set Abstract::Calculation

# OVERRIDES
def descendant?
  true
end

def calculator_class
  ::Calculate::Inheritance
end

def standard_formula_input input
  input.merge! not_researched: "false", unknown: "Unknown"
end

format do
  view :legend do
    return unless (ancestor = card.variables_card.item_names.first)
    nest ancestor, view: :legend
  end
end

format :html do
  view :formula do
    field_nest :variables, view: :descendant_formula
  end
end
