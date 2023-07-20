include_set Abstract::Hybrid
include_set Abstract::Calculation

# OVERRIDES
def descendant?
  true
end

def ten_scale?
  !direct_dependee_metrics.find { |m| !m.ten_scale? }
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
