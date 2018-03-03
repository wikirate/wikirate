include Set::Abstract::Calculation
include_set Set::Abstract::Hybrid

card_accessor :formula, type_id: PointerID

# <OVERRIDES>
def calculator_class
  ::Formula::Inheritance
end

def formula_editor
  :filtered_list
end
# </OVERRIDES>