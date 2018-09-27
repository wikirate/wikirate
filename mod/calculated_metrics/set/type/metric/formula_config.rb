# <OVERRIDES>
# note: the following only _really_ apply to calculated metrics and should arguably
# be in Abstract::Calculation.  However that breaks an API test that assumes formulas
# can be run on _any_ metric. If we're ok to remove that api, I'm happy to move this code
# -efm


def formula_editor
  :standard_formula_editor
end

def hidden_content_in_formula_editor?
  false
end

def formula_core
  :standard_formula_core
end

def formula_input_requirement
  :all
end

def calculator_class
  nil
end

# </OVERRIDES>
