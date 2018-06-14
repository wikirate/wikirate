include_set Abstract::Calculation
include_set Abstract::Hybrid

card_accessor :formula, type_id: PointerID

# OVERRIDES
def descendant?
  true
end

def calculator_class
  ::Formula::Inheritance
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

format :html do
  def tab_list
    %i[details score project]
  end

  def value_legend
    return unless (ancestor = card.formula_card.input_names.first)
    Card[ancestor]&.format&.value_legend
  end
end
