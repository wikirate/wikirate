include_set Abstract::Hybrid
include_set Abstract::Calculation

card_accessor :formula, type: PointerID

# OVERRIDES
def descendant?
  true
end

def calculator_class
  ::Calculate::Inheritance
end

def formula_editor
  :filtered_list
end

def hidden_content_in_formula_editor?
  true
end

def formula_core
  :ancestor_core
end

def formula_input_requirement
  :any
end

format do
  view :legend do
    return unless (ancestor = card.formula_card.input_names.first)
    nest ancestor, view: :legend
  end
end
