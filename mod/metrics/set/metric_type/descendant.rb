include_set Set::Abstract::Calculation
include_set Set::Abstract::Hybrid

card_accessor :formula, type_id: PointerID

# OVERRIDES
def descendant?
  true
end

def calculator_class
  ::Formula::Ruby
end

def formula_editor
  :filtered_list
end

def formula_core
  :ancestor_core
end
